terraform {
  required_version = ">=1.9.0"
  # required_version = ">=1.6.0" # gpg key expired

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "aws" {

  # Région AWS utilisée
  region = var.aws_region

  # Clé d'accès AWS
  access_key = var.access_key

  # Clé secrète AWS
  secret_key = var.secret_key
}
