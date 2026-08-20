# Demo – Création d'une clé KMS avec Terraform

## Objectifs

1. Installer le provider AWS
2. Créer une clé KMS
3. Créer l’alias `alias/student-main-key`
4. Vérifier la création de la clé
5. Supprimer les ressources une fois terminé

---

## 1. Installer le provider AWS

Crée un fichier `main.tf` :

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
```

Initialise le projet :

```bash
terraform init
```

---

## 2. Créer une clé KMS

Ajoute la ressource suivante dans `main.tf` :

```hcl
resource "aws_kms_key" "kms_key" {
  description             = "KMS key managed by Terraform"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
```

Ce bloc permet de :

- Créer une clé KMS symétrique.
- Activer la rotation automatique de la clé.
- Définir une période de 7 jours avant sa suppression définitive.

---

## 3. Créer l'alias `alias/student-main-key`

Ajoute :

```hcl
resource "aws_kms_alias" "kms_alias" {
  name          = "alias/student-main-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
```

L’alias permet d’identifier plus facilement la clé KMS.

La clé peut être référencée dans Terraform avec :

```text
aws_kms_key.kms_key.arn
```

Son ID peut être récupéré avec :

```text
aws_kms_key.kms_key.key_id
```

---

## 4. Créer la clé KMS sur AWS

Vérifie la configuration :

```bash
terraform fmt
terraform validate
terraform plan
```

Puis crée les ressources :

```bash
terraform apply
```

Terraform doit créer :

- 1 ressource `aws_kms_key`
- 1 ressource `aws_kms_alias`

---

## 5. Vérifier avec AWS CLI

Lister les clés KMS :

```bash
aws kms list-keys
```

Lister les alias :

```bash
aws kms list-aliases
```

Rechercher directement l’alias :

```bash
aws kms describe-key --key-id alias/student-main-key
```

---

## 6. Supprimer la clé KMS

Pour supprimer les ressources Terraform :

```bash
terraform destroy
```

L’alias est supprimé immédiatement.

La clé KMS n’est pas supprimée immédiatement car elle utilise :

```hcl
deletion_window_in_days = 7
```

Elle passe donc dans l’état :

```text
PendingDeletion
```

AWS la supprimera définitivement après 7 jours.