<!-- BEGIN_TF_DOCS -->
# AWS Amplify Backend Environment module.
Terraform module which creates SAF2.0 Amplify Backend Environment in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| [aws_amplify_backend_environment.amplify_backend_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_backend_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Unique ID for an Amplify app. | `string` | n/a | yes |
| <a name="input_deployment_artifacts"></a> [deployment\_artifacts](#input\_deployment\_artifacts) | Name of deployment artifacts. | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name for the backend environment. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | AWS CloudFormation stack name of a backend environment. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_backend_environment_all"></a> [amplify\_backend\_environment\_all](#output\_amplify\_backend\_environment\_all) | A map of aws amplify backend environment |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN for a backend environment that is part of an Amplify app. |
| <a name="output_id"></a> [id](#output\_id) | Unique ID of the Amplify backend environment. |

<!-- END_TF_DOCS -->