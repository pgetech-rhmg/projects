<!-- BEGIN_TF_DOCS -->
# AWS Elastic Beanstalk configuration template module.
Terraform module which creates SAF2.0 aws\_elastic\_beanstalk\_configuration\_template in AWS.

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
| [aws_elastic_beanstalk_configuration_template.configuration_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_configuration_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Name of the application to associate with this configuration template. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Short description of the Template. | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | The ID of the environment used with this configuration template. | `string` | `null` | no |
| <a name="input_setting"></a> [setting](#input\_setting) | Option settings to configure the new Environment. These override specific values that are set as defaults. | <pre>list(object({<br>    namespace = string<br>    name      = string<br>    value     = string<br>    resource  = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_solution_stack_name"></a> [solution\_stack\_name](#input\_solution\_stack\_name) | A solution stack to base your Template off of. | `string` | `null` | no |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | A unique name for this Template. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application"></a> [application](#output\_application) | Name of the application to associate with this configuration template. |
| <a name="output_aws_elastic_beanstalk_configuration_template_all"></a> [aws\_elastic\_beanstalk\_configuration\_template\_all](#output\_aws\_elastic\_beanstalk\_configuration\_template\_all) | Map of all aws\_elastic\_beanstalk\_configuration\_template attributes |
| <a name="output_description"></a> [description](#output\_description) | Description of the template. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The ID of the environment used with this configuration template. |
| <a name="output_name"></a> [name](#output\_name) | The name of the template. |
| <a name="output_solution_stack_name"></a> [solution\_stack\_name](#output\_solution\_stack\_name) | Name of the solution stack. |


<!-- END_TF_DOCS -->