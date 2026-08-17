/**
 * # Module racine
 *
 * - `source` : chemin vers le module local `lambda_s3`.
 * - `code_archive` : archive ZIP contenant le code Python déployé dans AWS Lambda.
 */


resource "random_string" "random" {
  special = false
  length  = 10
  upper   = false
}


module "lambda_s3" {
  source = "./module/lambda_s3"
  bucket_name  = "bucket-${random_string.random.result}"
  lambda_name  = "lambda-${random_string.random.result}"
  code_archive = "./data/lambda.zip"
}