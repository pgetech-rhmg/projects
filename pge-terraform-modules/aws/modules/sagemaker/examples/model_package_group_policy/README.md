<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker Model Package Group Policy example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_model_package_group_policy"></a> [model\_package\_group\_policy](#module\_model\_package\_group\_policy) | ../../modules/model_package_group_policy | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_model_package_group_name"></a> [model\_package\_group\_name](#input\_model\_package\_group\_name) | The name of the model package group. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_model_package_group_policy_id"></a> [model\_package\_group\_policy\_id](#output\_model\_package\_group\_policy\_id) | The name of the Model Package Package Group. |

<!-- END_TF_DOCS -->