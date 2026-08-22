# [CRÉATION] Génère une chaîne aléatoire de 10 caractères minuscules
# Sert de suffixe pour rendre les noms IAM uniques
resource "random_string" "random" {
  special = false
  length  = 10
  upper   = false
}

# [CONFIGURATION] Variables locales du module (aucune ressource créée)
# Actuellement non utilisées dans le code
locals {
  env = "dev"
  app = "proverb"
}

# [CRÉATION] Crée le bucket S3 source des fichiers à traiter
# force_destroy = true : autorise la destruction même si le bucket n'est pas vide
resource "aws_s3_bucket" "s3_module" {
  bucket        = "${var.bucket_name}"
  force_destroy = true
}

# [CONFIGURATION] Construit le document JSON de trust policy
# data source : rien n'est créé côté AWS, on prépare juste le JSON
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# [CRÉATION] Crée le rôle IAM d'exécution
# [LIAISON] assume_role_policy : rattache la trust policy définie au-dessus
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda-${random_string.random.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# [LIAISON] Attache une policy inline au rôle IAM (role = ...)
# [CONFIGURATION] Définit les droits accordés : logs CloudWatch + iam:PassRole
# Resource = "*" : périmètre trop large, à restreindre hors dev
resource "aws_iam_role_policy" "policy_one" {
  name = "plicy_for_lambda-${random_string.random.result}"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup", "logs:CreateLogStream",
          "logs:PutLogEvents", "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# [LIAISON] Autorise le bucket S3 (source_arn) à invoquer la Lambda (function_name)
# C'est la permission côté Lambda, indispensable avant de brancher la notification
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_module.arn
}

# [CRÉATION] Crée la fonction Lambda à partir de l'archive zip locale
# [LIAISON] role : rattache le rôle IAM créé plus haut
# [CONFIGURATION] runtime Python 3.10, point d'entrée lambda_function.lambda_handler
resource "aws_lambda_function" "func" {
  function_name = var.lambda_name
  filename      = var.code_archive
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
}

# [LIAISON] Branche le bucket S3 sur la Lambda (déclencheur)
# [CONFIGURATION] Filtre : uniquement les objets créés sous le préfixe "input/"
# depends_on : force la création de la permission avant la notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_module.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}