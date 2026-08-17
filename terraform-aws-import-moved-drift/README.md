# <span style="color:green; font-weight:bold">Terraform AWS — Import, moved et drift</span>


## Source
```
https://blog.stephane-robert.info/docs/infra-as-code/provisionnement/terraform/aws/import-moved-drift/
```

## Objectif

Ce lab montre comment reprendre avec Terraform une ressource AWS déjà existante, sans la recréer, puis faire évoluer proprement sa configuration.

Le workflow étudié est :

1. créer une instance EC2 de départ ;
2. la retirer du state Terraform sans la supprimer dans AWS ;
3. l'importer dans une nouvelle configuration Terraform ;
4. renommer son adresse Terraform avec `moved` sans recréer l'instance ;
5. provoquer volontairement un drift ;
6. détecter ce drift avec `terraform plan -refresh-only` ;
7. remettre l'infrastructure en conformité avec le code.

## Concepts principaux

| Concept | Rôle |
|---|---|
| `import` | Rattacher une ressource existante à Terraform |
| `moved` | Renommer ou déplacer une ressource Terraform sans la recréer |
| `drift` | Écart entre le code Terraform et l'infrastructure réelle |
| `terraform state rm` | Retirer une ressource du state sans la détruire |
| `terraform plan -refresh-only` | Observer les changements réalisés hors Terraform |

---

# Étape 1 — Préparer les répertoires

On utilise deux projets séparés :

- `seed/` : crée l'instance initiale ;
- `manage/` : récupère ensuite cette instance avec un import.

# Créer les répertoires du lab
```bash
mkdir -p ~/terraform-aws-import/{seed,manage}
cd ~/terraform-aws-import/seed
```

---

# Étape 2 — Créer l'instance EC2 de départ

Dans `seed/`, créer une configuration Terraform classique avec :

- le provider AWS ;
- une AMI Ubuntu ;
- une instance EC2 ;
- quelques variables ;
- des outputs.

# Initialiser le projet Terraform
```bash
terraform init
```

# Vérifier la syntaxe Terraform
```bash
terraform validate
```

# Créer l'instance EC2
```bash
terraform apply -auto-approve
```

# Afficher les outputs Terraform
```bash
terraform output
```

Noter notamment :

- `instance_id`
- `instance_ami_id`
- `instance_type`
- `instance_name`

Ces valeurs seront utilisées dans le projet `manage/`.

---

# Étape 3 — Retirer l'instance du state sans la supprimer

L'objectif est de simuler une ressource AWS existante qui n'est plus suivie par le state Terraform actuel.

# Retirer l'instance du state Terraform
```bash
terraform state rm aws_instance.seed_vm
```

Cette commande :

- ne supprime pas l'instance EC2 ;
- retire uniquement son association avec le state ;
- laisse la ressource active dans AWS.

# Vérifier que la ressource n'est plus dans le state
```bash
terraform state list
```

# Vérifier que l'instance existe toujours dans AWS
```bash
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxxxxxxxxxxx \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,Tags]' \
  --output table
```

---

# Étape 4 — Passer dans le projet de gestion

# Ouvrir le répertoire manage
```bash
cd ~/terraform-aws-import/manage
```

Le projet `manage/` va devenir le nouveau propriétaire Terraform de l'instance.

---

# Étape 5 — Déclarer l'import

Terraform permet depuis la version 1.5 d'utiliser un bloc déclaratif `import {}`.

Exemple :

```hcl
import {
  to = aws_instance.imported_vm
  id = var.instance_id
}
```

La ressource doit également être déclarée dans la configuration.

```hcl
resource "aws_instance" "imported_vm" {
  ami           = var.instance_ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

Le fichier `terraform.tfvars` doit contenir les informations de l'instance existante.

```hcl
aws_region      = "us-east-1"
instance_id     = "i-0abc123def4567890"
instance_ami_id = "ami-00de3875b03809ec5"
instance_type   = "t2.micro"
instance_name   = "terraform-import-seed"
```

---

# Étape 6 — Vérifier l'import avant application

# Initialiser le nouveau projet Terraform
```bash
terraform init
```

# Vérifier le plan d'import
```bash
terraform plan
```

Si la configuration correspond bien à la ressource existante, Terraform doit afficher quelque chose de proche de :

```text
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

---

# Étape 7 — Importer réellement l'instance

# Appliquer l'import
```bash
terraform apply -auto-approve
```

# Vérifier que l'instance apparaît maintenant dans le state
```bash
terraform state list
```

# Vérifier que Terraform ne prévoit plus de modification
```bash
terraform plan
```

Résultat attendu :

```text
No changes. Your infrastructure matches the configuration.
```

---

# Étape 8 — Alternative avec terraform import

Avant Terraform 1.5, l'import se faisait principalement avec la commande CLI suivante.

# Importer une ressource avec la commande historique
```bash
terraform import aws_instance.imported_vm i-0abc123def4567890
```

Cette méthode fonctionne toujours, mais elle modifie directement le state.

Le bloc `import {}` est généralement préférable car il passe par le workflow :

```text
terraform plan
        ↓
terraform apply
```

---

# Étape 9 — Renommer la ressource avec moved

Supposons que la ressource s'appelle actuellement :

```hcl
aws_instance.imported_vm
```

On veut la renommer en :

```hcl
aws_instance.production_web_server
```

La nouvelle ressource devient :

```hcl
resource "aws_instance" "production_web_server" {
  ami           = var.instance_ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

Puis on ajoute :

```hcl
moved {
  from = aws_instance.imported_vm
  to   = aws_instance.production_web_server
}
```

# Vérifier que Terraform comprend le déplacement
```bash
terraform plan
```

Terraform comprend alors qu'il s'agit du même objet AWS.

L'instance EC2 n'est donc pas détruite puis recréée.

---

# Étape 10 — Vérifier le nouvel état Terraform

# Afficher les ressources suivies dans le state
```bash
terraform state list
```

La nouvelle adresse doit apparaître :

```text
aws_instance.production_web_server
```

---

# Étape 11 — Provoquer volontairement un drift

On modifie directement le tag `Name` dans AWS, donc en dehors de Terraform.

# Modifier manuellement le tag Name avec AWS CLI
```bash
aws ec2 create-tags \
  --resources i-0abc123def4567890 \
  --tags Key=Name,Value=manual-change
```

Le code Terraform contient toujours :

```hcl
Name = "terraform-import-seed"
```

Mais AWS contient maintenant :

```text
Name = manual-change
```

Il y a donc un drift.

---

# Étape 12 — Détecter le drift

# Comparer le state avec l'infrastructure réelle
```bash
terraform plan -refresh-only
```

Terraform doit détecter une différence similaire à :

```text
"Name" = "terraform-import-seed" -> "manual-change"
```

`-refresh-only` permet d'observer les modifications réalisées hors Terraform sans corriger immédiatement l'infrastructure.

---

# Étape 13 — Corriger le drift

Dans ce lab, le code Terraform reste la source de vérité.

Il faut donc remettre AWS dans l'état décrit par Terraform.

# Réappliquer la configuration Terraform
```bash
terraform apply -auto-approve
```

Terraform remet le tag `Name` à la valeur définie dans le code.

# Vérifier que l'infrastructure est de nouveau alignée
```bash
terraform plan
```

Résultat attendu :

```text
No changes. Your infrastructure matches the configuration.
```

---

# Étape 14 — Accepter un drift au lieu de le corriger

Dans certains cas, la modification manuelle est volontaire et doit devenir le nouvel état de référence.

On peut alors utiliser :

# Mettre à jour uniquement le state à partir de la réalité
```bash
terraform apply -refresh-only
```

Cette commande :

- actualise le state ;
- ne remet pas l'infrastructure à la valeur du code ;
- accepte l'état réel comme nouvel état observé.

Il faudra ensuite éventuellement modifier le code Terraform pour éviter un nouveau drift.

---

# Ordre recommandé en production

Il vaut mieux séparer les opérations.

```text
Ressource existante
        ↓
Import
        ↓
terraform plan
        ↓
0 changement
        ↓
Refactoring
        ↓
moved {}
        ↓
terraform plan
        ↓
Gestion normale
```

Éviter de faire simultanément :

- un import ;
- un renommage ;
- une modification de configuration importante.

Cela complique fortement le diagnostic en cas de problème.

---

# Points importants sur l'import

Un import Terraform :

- ne génère pas automatiquement une configuration Terraform complète ;
- ne recrée pas la ressource ;
- associe une ressource existante à une adresse Terraform ;
- nécessite une configuration suffisamment proche de la réalité.

Une configuration trop incomplète peut provoquer un plan avec des modifications ou un remplacement de la ressource.

---

# Générer une configuration initiale

Pour une ressource complexe, Terraform peut aider à produire une première configuration.

# Générer une configuration à partir des ressources à importer
```bash
terraform plan -generate-config-out=generated.tf
```

Le fichier généré doit ensuite être relu et nettoyé avant utilisation.

---

# Bonnes pratiques

1. Importer la ressource.
2. Obtenir un `terraform plan` sans changement.
3. Vérifier le state.
4. Refactoriser ensuite.
5. Utiliser `moved {}` pour les changements d'adresse Terraform.
6. Tester le drift avec une modification simple et réversible, par exemple un tag.
7. Éviter de tester un drift sur un attribut qui force la recréation de la ressource.
8. Conserver les blocs `moved` tant qu'ils restent utiles pour les anciennes versions de la configuration.

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

# Afficher le plan
```bash
terraform plan
```

# Appliquer la configuration
```bash
terraform apply -auto-approve
```

# Lister le contenu du state
```bash
terraform state list
```

# Retirer une ressource du state sans la détruire
```bash
terraform state rm aws_instance.seed_vm
```

# Importer une ressource avec l'ancienne méthode CLI
```bash
terraform import aws_instance.imported_vm i-xxxxxxxxxxxxxxxxx
```

# Détecter un drift
```bash
terraform plan -refresh-only
```

# Accepter l'état réel dans le state
```bash
terraform apply -refresh-only
```

# Détruire les ressources gérées par Terraform
```bash
terraform destroy -auto-approve
```

---

# Nettoyage du lab

L'instance est maintenant gérée par `manage/`.

Il faut donc la détruire depuis ce répertoire.

# Détruire l'instance depuis le projet qui possède son state
```bash
cd ~/terraform-aws-import/manage
terraform destroy -auto-approve
```

# Supprimer les fichiers locaux Terraform du projet manage
```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```

# Nettoyer également le projet seed
```bash
cd ~/terraform-aws-import/seed
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```

---

# À retenir

```text
import
  ↓
Rattacher une ressource existante à Terraform

moved
  ↓
Changer son adresse Terraform sans recréer la ressource

drift
  ↓
Détecter un changement effectué hors Terraform

terraform state rm
  ↓
Retirer une ressource du state sans la supprimer

terraform plan -refresh-only
  ↓
Observer les différences entre le state et l'infrastructure réelle
```
