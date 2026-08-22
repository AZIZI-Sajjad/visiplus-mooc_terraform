

run "valid_names" {


  #TODO : Preciser le commande
  command = plan

  #TODO : Preciser le module
  module {
    source = "./module/lambda_s3"
  }

  #TODO : Preciser les variables en input
  variables {
    bucket_name  = "bucket-test"
    lambda_name  = "lambda-test"
    code_archive = "../../data/lambda.zip"
  }

  assert {
    condition     = aws_s3_bucket.s3_module.bucket == "bucket-test"
    error_message = "S3 bucket name did not match expected"
  }

  assert {
    condition     = aws_lambda_function.func.function_name == "lambda-test"
    error_message = "Lambda bucket name did not match expected"
  }

}