# Output de l'URL de l'API
output "api_url" {
  value = module.api_gateway.api_url
}

# TODO: Changer avec le nom du bucket
output "s3_url" {
  value = "http://${aws_s3_bucket.front_bucket.bucket}.s3-website.${var.aws_region}.amazonaws.com/index.html"
}
# output "s3_url" {
#   value = "https://${aws_s3_bucket.front_bucket.bucket}.${aws_region}.amazonaws.com/index.html"
# }