# TODO INIT TERRAFORM PROVIDERS
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO : CUSTOM AWS PROVIDER
provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  # Clé d'accès AWS
  access_key = var.access_key

  # Clé secrète AWS
  secret_key = var.secret_key
}


resource "local_file" "exemple" {
  content  = "Bonjour depuis Terraform"
  filename = "${path.module}/exemple.txt"
}

resource "aws_s3_bucket" "bucket_ireland" {
  provider = aws.eu_west_1

  bucket = "mon-bucket-demo-eu-west-1"
}


variable "access_key" {
  # Type de la variable
  type = string
}

# Variable pour la clé secrète AWS
variable "secret_key" {
  # Type de la variable
  type = string
}