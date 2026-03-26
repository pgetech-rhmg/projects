<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates Sagemaker Model

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
| [aws_sagemaker_model.sagemaker_model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containers"></a> [containers](#input\_containers) | primary\_container:<br/>  The primary docker image containing inference code that is used when the model is deployed for predictions. If not specified, the container argument is required.<br/>  container:<br/>  Specifies containers in the inference pipeline. If not specified, the primary\_container argument is required. | <pre>object({<br/>    primary_container = any<br/>    container         = list(any)<br/>  })</pre> | <pre>{<br/>  "container": [],<br/>  "primary_container": {}<br/>}</pre> | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | A role that SageMaker can assume to access model artifacts and docker images for deployment. | `string` | n/a | yes |
| <a name="input_inference_execution_config"></a> [inference\_execution\_config](#input\_inference\_execution\_config) | Specifies details of how containers in a multi-container endpoint are called. | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the model (must be unique). | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of IDs for the subnets that the file system will be accessible from. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_model_all"></a> [sagemaker\_model\_all](#output\_sagemaker\_model\_all) | A map of aws sagemaker model |
| <a name="output_sagemaker_model_arn"></a> [sagemaker\_model\_arn](#output\_sagemaker\_model\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this model. |
| <a name="output_sagemaker_model_name"></a> [sagemaker\_model\_name](#output\_sagemaker\_model\_name) | The name of the model |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->