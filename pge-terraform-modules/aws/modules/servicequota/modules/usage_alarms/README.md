<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.9 |
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
| [aws_cloudwatch_metric_alarm.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_name_prefix"></a> [alarm\_name\_prefix](#input\_alarm\_name\_prefix) | A string prefix for all cloudwatch alarms | `string` | `"service-quotas-"` | no |
| <a name="input_cloudwatch_alarm_actions"></a> [cloudwatch\_alarm\_actions](#input\_cloudwatch\_alarm\_actions) | Actions for all cloudwatch alarms. e.g. an SNS topic ARN | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_alarm_threshold"></a> [cloudwatch\_alarm\_threshold](#input\_cloudwatch\_alarm\_threshold) | The threshold for all cloudwatch alarms. This is a percentage of the limit so should be between 1-100 | `number` | `80` | no |
| <a name="input_disabled_services"></a> [disabled\_services](#input\_disabled\_services) | List of services to disable. See main.tf for list | `list(string)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | If set to false no cloudwatch alarms will be created | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to all cloudwatch alarms | `map(string)` | `{}` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->