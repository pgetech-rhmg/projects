<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates Sagemaker Project

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_project.project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | A description for the project. | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the Project. | `string` | n/a | yes |
| <a name="input_service_catalog_provisioning_details"></a> [service\_catalog\_provisioning\_details](#input\_service\_catalog\_provisioning\_details) | The product ID and provisioning artifact ID to provision a service catalog. | `list(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_arn"></a> [project\_arn](#output\_project\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Project. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The ID of the project. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | The name of the Project. |
| <a name="output_sagemaker_project_all"></a> [sagemaker\_project\_all](#output\_sagemaker\_project\_all) | A map of aws sagemaker project |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |

<!-- END_TF_DOCS -->