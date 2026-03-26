<!-- BEGIN_TF_DOCS -->
*#AWS Elastic Beanstalk module
*Terraform module which creates Elastic Beanstalk application version

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_application_version.application_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Name of the Beanstalk Application the version is associated with. | `string` | n/a | yes |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket that contains the Application Version source bundle. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Short description of the Application Version. | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | On delete, force an Application Version to be deleted when it may be in use by multiple Elastic Beanstalk Environments. | `bool` | `false` | no |
| <a name="input_key"></a> [key](#input\_key) | S3 object that is the Application Version source bundle. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the this Application Version. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN assigned by AWS for this Elastic Beanstalk Application. |
| <a name="output_aws_elastic_beanstalk_application_version_all"></a> [aws\_elastic\_beanstalk\_application\_version\_all](#output\_aws\_elastic\_beanstalk\_application\_version\_all) | Map of all aws\_elastic\_beanstalk\_application\_version attrivutes |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->