<!-- BEGIN_TF_DOCS -->
# Module lambda\_s3

Crée un bucket S3 et une fonction AWS Lambda.
Configure les permissions IAM nécessaires.
Déclenche automatiquement la Lambda lorsqu'un fichier est ajouté dans `input/`.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>=1.5.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

- <a name="requirement_local"></a> [local](#requirement\_local) (~> 2.4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.5.1)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 5.0)

- <a name="provider_random"></a> [random](#provider\_random) (3.5.1)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.policy_one](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_lambda_function.func](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) (resource)
- [aws_lambda_permission.allow_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) (resource)
- [aws_s3_bucket.s3_module](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) (resource)
- [random_string.random](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) (resource)
- [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: (Required) Bucket name where data is received

Type: `string`

### <a name="input_code_archive"></a> [code\_archive](#input\_code\_archive)

Description: (Required) lambda code to deploy.   
 chemin vers l'archive ZIP contenant le code Python déployé dans la fonction Lambda

Type: `string`

### <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name)

Description: (Required) Lambda name where data is processed

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name)

Description: n/a

### <a name="output_output_buket_name"></a> [output\_buket\_name](#output\_output\_buket\_name)

Description: n/a
<!-- END_TF_DOCS -->