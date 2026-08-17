variable "bucket_name" {
  description = "(Required) Bucket name where data is received"
  type = string
}

variable "lambda_name" {
  description = "(Required) Lambda name where data is processed"
  type = string
}


variable "code_archive" {
  description = "(Required) lambda code to deploy. \n chemin vers l'archive ZIP contenant le code Python déployé dans la fonction Lambda"
  type = string
}
