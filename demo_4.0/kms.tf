resource "aws_kms_key" "kms_key" {
  description             = "KMS key managed by Terraform"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/student-main-key"
  target_key_id = aws_kms_key.kms_key.key_id
}
