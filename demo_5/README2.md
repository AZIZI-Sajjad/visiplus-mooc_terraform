<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.58.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.s3_atelier_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [local_file.file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Variable pour la clé d'accès AWS | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Variable pour la région | `string` | n/a | yes |
| <a name="input_list_of_files"></a> [list\_of\_files](#input\_list\_of\_files) | List of files | `list(string)` | <pre>[<br/>  "file_first",<br/>  "file_second",<br/>  "file_third"<br/>]</pre> | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | Variable pour la clé secrète AWS | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->