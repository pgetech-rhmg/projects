<!-- BEGIN_TF_DOCS -->


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
| [aws_redshift_scheduled_action.scheduled_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_scheduled_action) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The unique identifier for the cluster to resize. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the scheduled action. | `string` | `null` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Whether to enable the scheduled action. | `bool` | `true` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | The IAM role to assume to run the scheduled | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The scheduled action name. | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule of action.The schedule is defined format of 'at expression' or 'cron expression', for example at(2016-03-04T17:27:00) or cron(0 10 ? * MON *). | `string` | n/a | yes |
| <a name="input_scheduled_actions"></a> [scheduled\_actions](#input\_scheduled\_actions) | Map of maps containing scheduled action defintions | `any` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_scheduled_action_all"></a> [aws\_redshift\_scheduled\_action\_all](#output\_aws\_redshift\_scheduled\_action\_all) | A map of aws redshift scheduled action resource attributes references |
| <a name="output_scheduled_action"></a> [scheduled\_action](#output\_scheduled\_action) | The Redshift Scheduled Action name. |

<!-- END_TF_DOCS -->