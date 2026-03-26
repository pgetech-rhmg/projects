<!-- BEGIN_TF_DOCS -->
*#AWS Elastic Beanstalk module
*Terraform module which creates Elastic Beanstalk application

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

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
| [aws_elastic_beanstalk_application.elastic_beanstalk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appversion_lifecycle"></a> [appversion\_lifecycle](#input\_appversion\_lifecycle) | service\_role :<br>   The ARN of an IAM service role under which the application version is deleted. Elastic Beanstalk must have permission to assume this role.<br>max\_count :<br>   The maximum number of application versions to retain ('max\_age\_in\_days' and 'max\_count' cannot be enabled simultaneously.).<br>max\_age\_in\_days :<br>   The number of days to retain an application version ('max\_age\_in\_days' and 'max\_count' cannot be enabled simultaneously.).<br>delete\_source\_from\_s3 : <br>   Set to true to delete a version's source bundle from S3 when the application version is deleted. | <pre>object({<br>    service_role          = string<br>    max_count             = optional(number)<br>    max_age_in_days       = optional(number)<br>    delete_source_from_s3 = optional(bool)<br>  })</pre> | <pre>{<br>  "delete_source_from_s3": true,<br>  "max_age_in_days": null,<br>  "max_count": null,<br>  "service_role": null<br>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Short description of the application | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the application, must be unique within your account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS for this Elastic Beanstalk Application. |
| <a name="output_aws_elastic_beanstalk_application_all"></a> [aws\_elastic\_beanstalk\_application\_all](#output\_aws\_elastic\_beanstalk\_application\_all) | A map of all aws\_elastic\_beanstalk\_application attributes |
| <a name="output_name"></a> [name](#output\_name) | The name assigned by AWS for this Elastic Beanstalk Application. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->