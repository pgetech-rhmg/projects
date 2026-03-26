<!-- BEGIN_TF_DOCS -->
# AWS route 53 health check module
Terraform module which creates SAF2.0 Route 53 health check in AWS. This module can be used in the scenario to check if the route53 designated resource is healthy or not. Example can be found at https://github.com/pgetech/multi-region-ha-dr-assessment/tree/main/acm.tf

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.1 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_health_check.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_child_health_threshold"></a> [child\_health\_threshold](#input\_child\_health\_threshold) | The minimum number of child health checks that must be healthy for Route 53 to consider the parent health check to be healthy | `number` | `null` | no |
| <a name="input_child_healthchecks"></a> [child\_healthchecks](#input\_child\_healthchecks) | For a specified parent health check, a list of HealthCheckId values for the associated child health checks | `list(string)` | `null` | no |
| <a name="input_cloudwatch_alarm_name"></a> [cloudwatch\_alarm\_name](#input\_cloudwatch\_alarm\_name) | The name of the CloudWatch alarm | `string` | `null` | no |
| <a name="input_cloudwatch_alarm_region"></a> [cloudwatch\_alarm\_region](#input\_cloudwatch\_alarm\_region) | The CloudWatchRegion that the CloudWatch alarm was created in | `string` | `null` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | A boolean value that stops Route 53 from performing health checks | `bool` | `null` | no |
| <a name="input_enable_sni"></a> [enable\_sni](#input\_enable\_sni) | A boolean value that indicates whether Route53 should send the fqdn to the endpoint when performing the health check | `bool` | `null` | no |
| <a name="input_failure_threshold"></a> [failure\_threshold](#input\_failure\_threshold) | The number of consecutive health checks that an endpoint must pass or fail | `number` | `null` | no |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | The fully qualified domain name of the endpoint to be checked | `string` | `null` | no |
| <a name="input_insufficient_data_health_status"></a> [insufficient\_data\_health\_status](#input\_insufficient\_data\_health\_status) | The status of the health check when CloudWatch has insufficient data about the state of associated alarm | `string` | `null` | no |
| <a name="input_invert_healthcheck"></a> [invert\_healthcheck](#input\_invert\_healthcheck) | A boolean value that indicates whether the status of health check should be inverted | `bool` | `null` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | The IP address of the endpoint to be checked | `string` | `null` | no |
| <a name="input_measure_latency"></a> [measure\_latency](#input\_measure\_latency) | A Boolean value that indicates whether you want Route 53 to measure the latency between health checkers in multiple AWS regions and your endpoint and to display CloudWatch latency graphs in the Route 53 console | `bool` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | The port of the endpoint to be checked | `number` | `null` | no |
| <a name="input_reference_name"></a> [reference\_name](#input\_reference\_name) | A reference name used in Caller Reference | `string` | `null` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | A list of AWS regions that you want Amazon Route 53 health checkers to check the specified endpoint from | `list(string)` | `null` | no |
| <a name="input_request_interval"></a> [request\_interval](#input\_request\_interval) | The number of seconds between the time that Amazon Route 53 gets a response from your endpoint and the time that it sends the next health-check request | `number` | `null` | no |
| <a name="input_resource_path"></a> [resource\_path](#input\_resource\_path) | The path that you want Amazon Route 53 to request when performing health checks | `string` | `null` | no |
| <a name="input_routing_control_arn"></a> [routing\_control\_arn](#input\_routing\_control\_arn) | The Amazon Resource Name (ARN) for the Route 53 Application Recovery Controller routing control | `string` | `null` | no |
| <a name="input_search_string"></a> [search\_string](#input\_search\_string) | String searched in the first 5120 bytes of the response body for check to be considered healthy | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The protocol to use when performing health checks | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_check_arn"></a> [health\_check\_arn](#output\_health\_check\_arn) | The Amazon Resource Name (ARN) of the Health Check |
| <a name="output_health_check_id"></a> [health\_check\_id](#output\_health\_check\_id) | The id of the health check |
| <a name="output_health_check_tags_all"></a> [health\_check\_tags\_all](#output\_health\_check\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |

<!-- END_TF_DOCS -->