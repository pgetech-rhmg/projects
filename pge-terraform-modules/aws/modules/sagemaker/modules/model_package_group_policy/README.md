<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates model\_package\_group\_policy

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
| [aws_sagemaker_model_package_group_policy.model_package_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model_package_group_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model_package_group_name"></a> [model\_package\_group\_name](#input\_model\_package\_group\_name) | The name of the model package group. | `string` | n/a | yes |
| <a name="input_model_package_group_resource_policy"></a> [model\_package\_group\_resource\_policy](#input\_model\_package\_group\_resource\_policy) | The resource policy for the model group. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_model_package_group_policy_id"></a> [model\_package\_group\_policy\_id](#output\_model\_package\_group\_policy\_id) | The name of the Model Package Package Group. |
| <a name="output_sagemaker_model_package_group_policy_all"></a> [sagemaker\_model\_package\_group\_policy\_all](#output\_sagemaker\_model\_package\_group\_policy\_all) | A map of aws sagemaker model package group policy |

<!-- END_TF_DOCS -->