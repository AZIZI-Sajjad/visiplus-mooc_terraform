variables {
  bucket_name  = "bucket-test"
  lambda_name  = "lambda-test"
  code_archive = "../../data/lambda.zip"
}

run "s3_bucket_name" {
  command = plan
  module {
    source = "./module/lambda_s3"
  }
  assert {
    condition     = aws_s3_bucket.s3_module.bucket == "bucket-test"
    error_message = "S3 bucket name did not match expected"
  }
}

run "s3_force_destroy" {
  command = plan
  module {
    source = "./module/lambda_s3"
  }
  assert {
    condition     = aws_s3_bucket.s3_module.force_destroy == true
    error_message = "force_destroy is not enabled on the S3 bucket"
  }
}

run "lambda_function_name" {
  command = plan
  module {
    source = "./module/lambda_s3"
  }
  assert {
    condition     = aws_lambda_function.func.function_name == "lambda-test"
    error_message = "Lambda function name did not match expected"
  }
}

run "lambda_runtime" {
  command = plan
  module {
    source = "./module/lambda_s3"
  }
  assert {
    condition     = aws_lambda_function.func.runtime == "python3.10"
    error_message = "Lambda runtime did not match expected"
  }
}