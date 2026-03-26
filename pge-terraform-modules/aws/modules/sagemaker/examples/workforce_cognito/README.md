<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker workforce
# Terraform module which creates Sagemaker workforce

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sagemaker_workforce"></a> [sagemaker\_workforce](#module\_sagemaker\_workforce) | ../../modules/workforce | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.user_pool_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cidrs"></a> [cidrs](#input\_cidrs) | A list of IP address ranges Used to create an allow list of IP addresses for a private workforce. By default, a workforce isn't restricted to specific IP addresses. | `list(any)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Workforce (must be unique). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workforce_arn"></a> [workforce\_arn](#output\_workforce\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Workforce. |
| <a name="output_workforce_id"></a> [workforce\_id](#output\_workforce\_id) | The name of the Workforce. |
| <a name="output_workforce_subdomain"></a> [workforce\_subdomain](#output\_workforce\_subdomain) | The subdomain for your OIDC Identity Provider. |

<!-- END_TF_DOCS -->