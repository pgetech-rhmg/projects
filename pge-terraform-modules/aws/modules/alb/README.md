<!-- BEGIN_TF_DOCS -->
AWS Application Load Balancer
Terraform module which creates SAF2.0 AWS Application Load Balancer

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.77.0 |

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
| [aws_lb.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.lb_listener_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.lb_listener_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.lb_listener_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.lb_listener_rule_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.lb_listener_rule_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb on AWS | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the s3 bucket to store alb logs on AWS | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate to attach to the listener. | `list(map(string))` | `[]` | no |
| <a name="input_customer_owned_ipv4_pool"></a> [customer\_owned\_ipv4\_pool](#input\_customer\_owned\_ipv4\_pool) | The ID of the customer owned ipv4 pool to use for this load balancer. | `string` | `null` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. | `string` | `null` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Indicates whether HTTP/2 is enabled in the load balancer. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_waf_fail_open"></a> [enable\_waf\_fail\_open](#input\_enable\_waf\_fail\_open) | Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. | `bool` | `true` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. Default: 60. | `number` | `60` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. Defaults to ipv4 | `string` | `null` | no |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | `[]` | no |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | `[]` | no |
| <a name="input_lb_listener_rule_http"></a> [lb\_listener\_rule\_http](#input\_lb\_listener\_rule\_http) | A list of maps describing the listener rules for ALB. | `any` | `[]` | no |
| <a name="input_lb_listener_rule_https"></a> [lb\_listener\_rule\_https](#input\_lb\_listener\_rule\_https) | A list of maps describing the listener rules for ALB. | `any` | `[]` | no |
| <a name="input_lb_target_group"></a> [lb\_target\_group](#input\_lb\_target\_group) | A list of maps containing key/value pairs for the target groups to be created for ALB. | `any` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to assign to the LB. | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of private subnet IDs to attach to the LB if it is INTERNAL. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Identifier of the VPC in which to create the target group. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb"></a> [alb](#output\_alb) | Map of ALB object |
| <a name="output_alb_listener_http"></a> [alb\_listener\_http](#output\_alb\_listener\_http) | Map of ALB http listener object |
| <a name="output_alb_listener_https"></a> [alb\_listener\_https](#output\_alb\_listener\_https) | Map of ALB https listener object |
| <a name="output_alb_listener_rule_http"></a> [alb\_listener\_rule\_http](#output\_alb\_listener\_rule\_http) | Map of ALB http listener rule object |
| <a name="output_alb_listener_rule_https"></a> [alb\_listener\_rule\_https](#output\_alb\_listener\_rule\_https) | Map of ALB https listener rule object |
| <a name="output_alb_target_group"></a> [alb\_target\_group](#output\_alb\_target\_group) | Map of ALB target-group object |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the load balancer (matches id). |
| <a name="output_lb_arn_suffix"></a> [lb\_arn\_suffix](#output\_lb\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | The id of the load balancer (matches arn). |
| <a name="output_lb_listener_certificate"></a> [lb\_listener\_certificate](#output\_lb\_listener\_certificate) | The listener\_arn and certificate\_arn separated by a \_. |
| <a name="output_lb_target_group_attachment_id"></a> [lb\_target\_group\_attachment\_id](#output\_lb\_target\_group\_attachment\_id) | A unique identifier for the attachment. |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
| <a name="output_listener_http_arn"></a> [listener\_http\_arn](#output\_listener\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_http_id"></a> [listener\_http\_id](#output\_listener\_http\_id) | ARN of the listener (matches arn). |
| <a name="output_listener_http_tags_all"></a> [listener\_http\_tags\_all](#output\_listener\_http\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_listener_https_arn"></a> [listener\_https\_arn](#output\_listener\_https\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_https_id"></a> [listener\_https\_id](#output\_listener\_https\_id) | ARN of the listener (matches arn). |
| <a name="output_listener_https_tags_all"></a> [listener\_https\_tags\_all](#output\_listener\_https\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_listener_rule_http_arn"></a> [listener\_rule\_http\_arn](#output\_listener\_rule\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_rule_http_id"></a> [listener\_rule\_http\_id](#output\_listener\_rule\_http\_id) | ARN of the listener (matches arn). |
| <a name="output_listener_rule_http_tags_all"></a> [listener\_rule\_http\_tags\_all](#output\_listener\_rule\_http\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_listener_rule_https_arn"></a> [listener\_rule\_https\_arn](#output\_listener\_rule\_https\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_rule_https_id"></a> [listener\_rule\_https\_id](#output\_listener\_rule\_https\_id) | ARN of the listener (matches arn). |
| <a name="output_listener_rule_https_tags_all"></a> [listener\_rule\_https\_tags\_all](#output\_listener\_rule\_https\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the Target Group (matches id). |
| <a name="output_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#output\_target\_group\_arn\_suffix) | ARN suffix for use with CloudWatch Metrics. |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | ARN of the Target Group (matches arn). |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the Target Group. |
| <a name="output_target_group_tags_all"></a> [target\_group\_tags\_all](#output\_target\_group\_tags\_all) | ARN suffix for use with CloudWatch Metrics. |

<!-- END_TF_DOCS -->