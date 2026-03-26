<!-- BEGIN_TF_DOCS -->
# AWS sagemaker workforce module
# Terraform module which creates Sagemaker workforce

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_workforce.sagemaker_workforce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_workforce) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidrs"></a> [cidrs](#input\_cidrs) | A list of IP address ranges Used to create an allow list of IP addresses for a private workforce. By default, a workforce isn't restricted to specific IP addresses. | `list(any)` | n/a | yes |
| <a name="input_cognito_oidc"></a> [cognito\_oidc](#input\_cognito\_oidc) | An object variable contains cognito\_config and oidc\_config to avoid the conflict between cognito and oidc configurations | <pre>object({<br/>    cognito_config = any<br/>    oidc_config    = any<br/>  })</pre> | <pre>{<br/>  "cognito_config": {},<br/>  "oidc_config": {}<br/>}</pre> | no |
| <a name="input_workforce_name"></a> [workforce\_name](#input\_workforce\_name) | The name of the Workforce (must be unique). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_workforce_all"></a> [sagemaker\_workforce\_all](#output\_sagemaker\_workforce\_all) | A map of aws sagemaker workforce |
| <a name="output_workforce_arn"></a> [workforce\_arn](#output\_workforce\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Workforce. |
| <a name="output_workforce_id"></a> [workforce\_id](#output\_workforce\_id) | The name of the Workforce. |
| <a name="output_workforce_subdomain"></a> [workforce\_subdomain](#output\_workforce\_subdomain) | The subdomain for your OIDC Identity Provider. |

<!-- END_TF_DOCS -->