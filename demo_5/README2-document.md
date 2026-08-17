# terraform-docs

`terraform-docs` est un outil permettant de générer automatiquement de la documentation à partir de fichiers Terraform.

Il analyse notamment :

- les variables ;
- les outputs ;
- les providers ;
- les ressources ;
- les modules ;
- les requirements Terraform ;
- les versions des providers.

---

## Installation

### Linux / WSL Ubuntu

Définir la version à installer :

```bash
VERSION="v0.24.0"
```

Télécharger l'archive :

```bash
wget https://github.com/terraform-docs/terraform-docs/releases/download/${VERSION}/terraform-docs-${VERSION}-linux-amd64.tar.gz
```

Extraire l'archive :

```bash
tar -xzf terraform-docs-${VERSION}-linux-amd64.tar.gz
```

Installer le binaire :

```bash
sudo mv terraform-docs /usr/local/bin/
```

Vérifier l'installation :

```bash
terraform-docs --version
```

---

## Voir les versions disponibles

Les différentes versions sont disponibles ici :

```text
https://github.com/terraform-docs/terraform-docs/releases
```

Récupérer la dernière version avec l'API GitHub :

```bash
curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest \
| grep '"tag_name"'
```

Afficher plusieurs versions :

```bash
curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases \
| grep '"tag_name"'
```

---

## Utilisation

Se placer dans le dossier contenant les fichiers Terraform :

```bash
cd mon-projet-terraform/
```

Exemple d'arborescence :

```text
mon-projet-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── README.md
```

---

## Générer la documentation

### Markdown sous forme de tableau

```bash
terraform-docs markdown table .
```

Exemple :

```md
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | Région AWS | `string` | `"eu-west-3"` | no |
```

---

### Markdown sous forme de document

```bash
terraform-docs markdown document .
```

Ce format génère chaque variable et output dans une section dédiée.

---

## Formats disponibles

| Format | Commande |
|---|---|
| Markdown Table | `terraform-docs markdown table .` |
| Markdown Document | `terraform-docs markdown document .` |
| AsciiDoc Table | `terraform-docs asciidoc table .` |
| AsciiDoc Document | `terraform-docs asciidoc document .` |
| JSON | `terraform-docs json .` |
| YAML | `terraform-docs yaml .` |
| XML | `terraform-docs xml .` |
| TOML | `terraform-docs toml .` |
| Pretty | `terraform-docs pretty .` |
| tfvars HCL | `terraform-docs tfvars hcl .` |
| tfvars JSON | `terraform-docs tfvars json .` |

---

## Générer du JSON

```bash
terraform-docs json .
```

Pratique pour exploiter les informations Terraform depuis :

- Bash ;
- Python ;
- PowerShell ;
- CI/CD ;
- API ;
- outils d'automatisation.

---

## Générer du YAML

```bash
terraform-docs yaml .
```

---

## Générer un fichier tfvars

### HCL

```bash
terraform-docs tfvars hcl .
```

### JSON

```bash
terraform-docs tfvars json .
```

Exemple :

```hcl
region        = "eu-west-3"
instance_type = "t3.micro"
```

---

## Générer automatiquement le README.md

Pour écrire directement la documentation dans un fichier :

```bash
terraform-docs markdown table \
  --output-file README.md \
  --output-mode inject \
  .
```

---

## Mode inject

Le mode `inject` permet de conserver le contenu manuel du `README.md` et de remplacer uniquement la partie générée par `terraform-docs`.

Ajouter dans le `README.md` :

```html
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

Exemple :

```md
# Mon infrastructure Terraform

Ce projet permet de déployer une infrastructure AWS.

## Documentation Terraform

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Utilisation

terraform init
terraform plan
terraform apply
```

Puis lancer :

```bash
terraform-docs markdown table \
  --output-file README.md \
  --output-mode inject \
  .
```

La documentation sera automatiquement ajoutée entre :

```text
<!-- BEGIN_TF_DOCS -->
```

et :

```text
<!-- END_TF_DOCS -->
```

---

## Voir l'aide

Afficher l'aide générale :

```bash
terraform-docs --help
```

Afficher l'aide pour Markdown :

```bash
terraform-docs markdown --help
```

Afficher l'aide pour le format tableau :

```bash
terraform-docs markdown table --help
```

---

## Exemple de workflow

```bash
terraform fmt
terraform validate
terraform-docs markdown table --output-file README.md --output-mode inject .
terraform plan
```

Cela permet de :

```text
Code Terraform
      ↓
terraform fmt
      ↓
terraform validate
      ↓
terraform-docs
      ↓
README.md mis à jour
      ↓
terraform plan
```

---

## Cas d'utilisation

`terraform-docs` est particulièrement utile pour :

- documenter automatiquement les modules Terraform ;
- maintenir les README à jour ;
- éviter de documenter manuellement les variables ;
- documenter les outputs ;
- intégrer la documentation dans une pipeline CI/CD ;
- générer des fichiers exploitables en JSON ou YAML ;
- standardiser la documentation des projets Terraform.

---

## Liens utiles

Site officiel :

```text
https://terraform-docs.io/
```

GitHub :

```text
https://github.com/terraform-docs/terraform-docs
```

Releases :

```text
https://github.com/terraform-docs/terraform-docs/releases
```