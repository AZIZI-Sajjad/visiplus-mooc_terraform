variable "bucket_name" {
  description = "(Required) Bucket name where data is received"
  type = string
}

variable "lambda_name" {
  description = "(Required) Lambda name where data is processed"
  type = string
}


variable "code_archive" {
  description = "(Required) lambda code to deploy"
  type = string
}

# Variable pour la clé d'accès AWS
variable "access_key" {
  # Type de la variable
  type = string
  description = "(Required) For connexion to aws"
}

# Variable pour la clé secrète AWS
variable "secret_key" {
  # Type de la variable
  type = string
  description = "(Required) For connexion to aws"
}

# Variable pour la région
variable "aws_region" {
  # Type de la variable
  type = string
  description = "(Required) For provider's configurations"

}



