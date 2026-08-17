<!-- BEGIN_TF_DOCS -->
# Module racine

- `source` : chemin vers le module local `lambda_s3`.
- `code_archive` : archive ZIP contenant le code Python déployé dans AWS Lambda.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>=1.5.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.0)

- <a name="requirement_local"></a> [local](#requirement\_local) (~> 2.4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.5.1)

## Providers

The following providers are used by this module:

- <a name="provider_random"></a> [random](#provider\_random) (3.5.1)

## Modules

The following Modules are called:

### <a name="module_lambda_s3"></a> [lambda\_s3](#module\_lambda\_s3)

Source: ./module/lambda_s3

Version:

## Resources

The following resources are used by this module:

- [random_string.random](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) (resource)

## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->