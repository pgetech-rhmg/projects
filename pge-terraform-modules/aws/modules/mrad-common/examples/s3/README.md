<!-- BEGIN_TF_DOCS -->
# mrad-common usage example.
Terraform module which creates SAF2.0 common MRAD related resources in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |

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
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.mrad-common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.sumo_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number - predefined in TFC | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number for Route 53 DNS resources | `string` | `""` | no |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume for managing Route 53 DNS resources | `string` | `""` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume - predefined in TFC | `string` | n/a | yes |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | ASM secret name for GitHub token | `string` | `"MRAD_GITHUB_TOKEN"` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub token used for API access | `string` | `"MRAD_GITHUB_TOKEN"` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->