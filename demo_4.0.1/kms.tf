resource "aws_kms_key" "kms_key" {
  description             = "KMS key managed by Terraform"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# resource "aws_kms_alias" "kms_alias" {
#   name          = "alias/student-main-key"
#   target_key_id = aws_kms_key.kms_key.key_id
# }

import {
  to = aws_kms_key.kms_key
  id = "d1a26744-96db-4840-ab33-395d5fca8a94"
}
