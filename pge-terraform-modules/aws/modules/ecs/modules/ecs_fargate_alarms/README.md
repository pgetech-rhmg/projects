<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
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
| [aws_cloudwatch_metric_alarm.CPUUtilization_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.HTTPCode_ELB_5XX_Count_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.MemoryUtilization_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_HTTPCode_ELB_5XX_threshold"></a> [HTTPCode\_ELB\_5XX\_threshold](#input\_HTTPCode\_ELB\_5XX\_threshold) | Threshold for ELB 5XX alert | `string` | `"25"` | no |
| <a name="input_alert_actions"></a> [alert\_actions](#input\_alert\_actions) | List of ARN of action to take on alarms, e.g. SNS topics | `list(any)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster. | `string` | n/a | yes |
| <a name="input_cpu_alert_threshold"></a> [cpu\_alert\_threshold](#input\_cpu\_alert\_threshold) | Threshold which will trigger a alert when the cpu crosses | `number` | `"80"` | no |
| <a name="input_lb_arn_suffix"></a> [lb\_arn\_suffix](#input\_lb\_arn\_suffix) | Enter the lb\_arn\_suffix to monitor | `string` | n/a | yes |
| <a name="input_memory_alert_threshold"></a> [memory\_alert\_threshold](#input\_memory\_alert\_threshold) | Threshold which will trigger a alert when the memory crosses | `number` | `"80"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Enter the name of the service to be monitored. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->