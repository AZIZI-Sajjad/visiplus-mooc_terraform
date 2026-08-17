# Projet Terraform AWS — 3 EC2 + S3

## Objectif

Ce lab permet de tester les mécanismes Terraform suivants :

- `terraform state rm`
- `import {}`
- `moved {}`
- détection du drift
- correction du drift

Infrastructure utilisée :

- 1 VPC
- 1 subnet public
- 1 Security Group
- 3 instances EC2
- 1 bucket S3

Projet de base :

https://github.com/egezamb/aws-terraform-starter

Architecture :

```text
AWS
│
├── VPC
│   └── Subnet public
│       ├── EC2 web
│       ├── EC2 app
│       └── EC2 db
│
└── S3
```

---

# Étape 1 — Cloner le projet

# Cloner le repository
```bash
git clone https://github.com/egezamb/aws-terraform-starter.git
```

# Entrer dans le projet
```bash
cd aws-terraform-starter
rm -rf .github
rm -rf .gitignore
```

# Créer le fichier de variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

---

# Étape 2 — Créer 3 instances EC2

Modifier la ressource EC2 pour utiliser `for_each`.

```hcl
locals {
  instances = {
    web = "t3.micro"
    app = "t3.micro"
    db  = "t3.micro"
  }
}

resource "aws_instance" "server" {
  for_each = local.instances

  ami           = data.aws_ami.amazon_linux.id
  instance_type = each.value

  tags = {
    Name = "terraform-${each.key}"
  }
}
```

Les instances auront les adresses Terraform suivantes :

```text
aws_instance.server["web"]
aws_instance.server["app"]
aws_instance.server["db"]
```

---

# Étape 3 — Initialiser Terraform

# Initialiser le projet
```bash
terraform init
```

# Vérifier la configuration
```bash
terraform validate
```

# Afficher le plan
```bash
terraform plan
```

---

# Étape 4 — Déployer l'infrastructure

# Créer les ressources AWS
```bash
terraform apply -auto-approve
```

# Afficher les ressources présentes dans le state
```bash
terraform state list
```

Résultat attendu proche de :

```text
aws_instance.server["web"]
aws_instance.server["app"]
aws_instance.server["db"]
aws_s3_bucket.<nom_du_bucket>
```

---

# Étape 5 — Simuler une ressource existante hors state

On retire l'EC2 `web` du state Terraform sans la supprimer dans AWS.

# Retirer l'EC2 web du state
```bash
terraform state rm 'aws_instance.server["web"]'
```

# Vérifier le contenu du state
```bash
terraform state list
```

L'instance existe toujours dans AWS, mais Terraform ne la gère plus.

Cela simule une ressource :

- créée manuellement ;
- créée par un ancien projet Terraform ;
- créée avec un autre outil IaC.

---

# Étape 6 — Retrouver l'instance EC2

# Afficher les instances et leur tag Name
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Exemple :

```text
i-0123456789abcdef0    terraform-web
i-0123456789abcdef1    terraform-app
i-0123456789abcdef2    terraform-db
```

Noter l'ID de l'instance `web`.

---

# Étape 7 — Préparer l'import

Déclarer une ressource correspondant à l'instance existante.

```hcl
resource "aws_instance" "web_imported" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-web"
  }
}
```

Ajouter le bloc `import`.

```hcl
import {
  to = aws_instance.web_imported
  id = "i-0123456789abcdef0"
}
```

Le principe est :

```text
EC2 déjà présente dans AWS
        ↓
import {}
        ↓
Terraform rattache l'EC2
à son state
```

---

# Étape 8 — Vérifier l'import

# Prévisualiser l'import
```bash
terraform plan
```

Résultat attendu si la configuration correspond à AWS :

```text
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

---

# Étape 9 — Effectuer l'import

# Appliquer l'import
```bash
terraform apply -auto-approve
```

# Vérifier le state
```bash
terraform state list
```

La ressource doit apparaître :

```text
aws_instance.web_imported
```

---

# Étape 10 — Vérifier l'alignement

# Vérifier qu'aucune modification n'est prévue
```bash
terraform plan
```

Résultat attendu :

```text
No changes. Your infrastructure matches the configuration.
```

---

# Étape 11 — Renommer la ressource avec moved

On veut passer de :

```text
aws_instance.web_imported
```

à :

```text
aws_instance.web_production
```

Renommer la ressource :

```hcl
resource "aws_instance" "web_production" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-web"
  }
}
```

Ajouter le bloc `moved`.

```hcl
moved {
  from = aws_instance.web_imported
  to   = aws_instance.web_production
}
```

---

# Étape 12 — Vérifier le moved

# Vérifier le changement d'adresse
```bash
terraform plan
```

Terraform doit comprendre qu'il s'agit toujours de la même EC2.

```text
aws_instance.web_imported
        ↓
aws_instance.web_production
```

La ressource AWS ne doit pas être détruite puis recréée.

# Appliquer le déplacement
```bash
terraform apply -auto-approve
```

# Vérifier la nouvelle adresse dans le state
```bash
terraform state list
```

---

# Étape 13 — Provoquer volontairement un drift

Modifier le tag `Name` directement avec AWS CLI.

# Modifier l'EC2 en dehors de Terraform
```bash
aws ec2 create-tags \
  --resources i-0123456789abcdef0 \
  --tags Key=Name,Value=modification-manuelle
```

Terraform contient :

```text
Name = terraform-web
```

AWS contient maintenant :

```text
Name = modification-manuelle
```

Il y a donc un drift.

---

# Étape 14 — Détecter le drift

# Comparer le state avec l'infrastructure AWS
```bash
terraform plan -refresh-only
```

Terraform doit détecter la modification effectuée hors Terraform.

```text
terraform-web
        ↓
modification-manuelle
```

---

# Étape 15 — Corriger le drift

Si le code Terraform reste la source de vérité :

# Remettre AWS en conformité avec Terraform
```bash
terraform apply -auto-approve
```

# Vérifier que l'infrastructure est de nouveau alignée
```bash
terraform plan
```

Résultat attendu :

```text
No changes. Your infrastructure matches the configuration.
```

---

# Étape 16 — Tester le drift sur S3

On peut également modifier le bucket S3 directement dans AWS.

# Ajouter manuellement un tag au bucket
```bash
aws s3api put-bucket-tagging \
  --bucket NOM_DU_BUCKET \
  --tagging 'TagSet=[{Key=Environment,Value=manual}]'
```

# Détecter la modification
```bash
terraform plan -refresh-only
```

---

# Import vs moved vs drift

| Concept | Fonction |
|---|---|
| `terraform state rm` | Retirer une ressource du state sans la détruire |
| `import {}` | Rattacher une ressource AWS existante à Terraform |
| `moved {}` | Modifier son adresse Terraform sans recréer la ressource |
| Drift | Modification de l'infrastructure réalisée hors Terraform |
| `terraform plan -refresh-only` | Détecter les différences entre le state et AWS |
| `terraform apply` | Remettre AWS en conformité avec le code |

---

# Workflow complet

```text
terraform apply
        ↓
Infrastructure AWS créée
        ↓
terraform state rm
        ↓
Ressource toujours présente dans AWS
mais absente du state
        ↓
import {}
        ↓
Terraform reprend la gestion
de la ressource existante
        ↓
terraform plan
        ↓
0 modification
        ↓
moved {}
        ↓
Renommage de la ressource Terraform
sans recréer l'EC2
        ↓
Modification manuelle dans AWS
        ↓
Drift
        ↓
terraform plan -refresh-only
        ↓
Détection du drift
        ↓
terraform apply
        ↓
Infrastructure de nouveau conforme
au code Terraform
```

---

# Bonnes pratiques

1. Commencer par créer une infrastructure stable.
2. Tester `terraform state rm` sur une seule ressource.
3. Vérifier dans AWS que la ressource existe toujours.
4. Importer la ressource.
5. Obtenir un `terraform plan` sans changement.
6. Tester ensuite `moved`.
7. Vérifier qu'aucune destruction n'est prévue.
8. Introduire un drift simple et réversible.
9. Pour un lab, privilégier les modifications de tags.
10. Éviter de tester le drift sur un attribut pouvant forcer le remplacement d'une EC2.

---

# Commandes essentielles

# Initialiser Terraform
```bash
terraform init
```

# Vérifier la configuration
```bash
terraform validate
```

# Vérifier les changements
```bash
terraform plan
```

# Créer l'infrastructure
```bash
terraform apply -auto-approve
```

# Lister les ressources du state
```bash
terraform state list
```

# Examiner une EC2 dans le state
```bash
terraform state show 'aws_instance.server["web"]'
```

# Retirer une EC2 du state sans la supprimer
```bash
terraform state rm 'aws_instance.server["web"]'
```

# Importer une ressource avec l'ancienne méthode CLI
```bash
terraform import aws_instance.web_imported i-0123456789abcdef0
```

# Détecter un drift
```bash
terraform plan -refresh-only
```

# Accepter l'état réel dans le state
```bash
terraform apply -refresh-only
```

# Remettre AWS en conformité avec le code
```bash
terraform apply -auto-approve
```

# Détruire le lab
```bash
terraform destroy -auto-approve
```