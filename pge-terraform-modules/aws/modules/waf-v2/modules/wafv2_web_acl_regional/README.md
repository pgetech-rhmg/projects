<!-- BEGIN_TF_DOCS -->
# AWS WAF Web ACL Regional module
Terraform module which creates SAF2.0 WAF Web ACL Regional in AWS

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.wafv2-web-acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.waf2_web_acl_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.wafv2-aws_wafv2_web_acl_logging_configuration-acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byte_match_rule"></a> [byte\_match\_rule](#input\_byte\_match\_rule) | Rule statement that defines a string match search for AWS WAF to apply to web requests. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules | `list(any)` | `[]` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | A boolean indicating whether the associated resource sends metrics to CloudWatch | `bool` | n/a | yes |
| <a name="input_custom_response_body"></a> [custom\_response\_body](#input\_custom\_response\_body) | key:<br> Unique key identifying the custom response body. This is referenced by the custom\_response\_body\_key argument in the Custom Response block.<br>content:<br> Payload of the custom response.<br>content\_type:<br> Type of content in the payload that you are defining in the content argument. Valid values are TEXT\_PLAIN, TEXT\_HTML, or APPLICATION\_JSON. | <pre>list(object({<br>    key          = string<br>    content      = string<br>    content_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_enable_webacl_resource_association"></a> [enable\_webacl\_resource\_association](#input\_enable\_webacl\_resource\_association) | Specifies if web acl association is to be enabled or not. The Boolean value to be enabled while associating waf with an Application Load Balancer or an Amazon API Gateway stage. | `bool` | `false` | no |
| <a name="input_geo_match_statement_rules"></a> [geo\_match\_statement\_rules](#input\_geo\_match\_statement\_rules) | List of geo match statement WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | `list(any)` | `[]` | no |
| <a name="input_ipset_reference_rules"></a> [ipset\_reference\_rules](#input\_ipset\_reference\_rules) | List of ipset reference WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | `list(any)` | `[]` | no |
| <a name="input_label_match_statement_rules"></a> [label\_match\_statement\_rules](#input\_label\_match\_statement\_rules) | List of label match statement WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | `list(any)` | `[]` | no |
| <a name="input_log_destination_arn"></a> [log\_destination\_arn](#input\_log\_destination\_arn) | arn for capturing logs from WebACL. | `string` | n/a | yes |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | `{}` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    override_action = string<br>    excluded_rules  = list(string)<br>    scope_down_statement = optional(object({<br>      ip_set_reference_statement = optional(object({<br>        arn = string<br>        ip_set_forwarded_ip_config = optional(object({<br>          fallback_behavior = string<br>          header_name       = string<br>          position          = string<br>        }))<br>      }))<br>      geo_match_statement = optional(object({<br>        country_codes = list(string)<br>        forwarded_ip_config = optional(object({<br>          fallback_behavior = string<br>          header_name       = string<br>        }))<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (\_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF for example All and Default\_Action. | `string` | n/a | yes |
| <a name="input_rate_based_rules"></a> [rate\_based\_rules](#input\_rate\_based\_rules) | List of rate based WAF rules. For more details refer: https://registry.terraform.io/providers/hashicorp/aws/4.0.0/docs/resources/wafv2_web_acl#rules. | `list(any)` | `[]` | no |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `any` | `[]` | no |
| <a name="input_request_default_action"></a> [request\_default\_action](#input\_request\_default\_action) | The action to perform if none of the rules contained in the WebACL match. | `string` | n/a | yes |
| <a name="input_resource_arn_to_associate_with_web_acl"></a> [resource\_arn\_to\_associate\_with\_web\_acl](#input\_resource\_arn\_to\_associate\_with\_web\_acl) | The Amazon Resource Name (ARN) of the resource to associate with the web ACL. This must be an ARN of an Application Load Balancer or an Amazon API Gateway stage. | `string` | `null` | no |
| <a name="input_rule_visibility_enable_cloudwatch_metrics"></a> [rule\_visibility\_enable\_cloudwatch\_metrics](#input\_rule\_visibility\_enable\_cloudwatch\_metrics) | Whether the associated resource sends metrics to CloudWatch. | `bool` | `true` | no |
| <a name="input_rule_visibility_enable_sampled_requests"></a> [rule\_visibility\_enable\_sampled\_requests](#input\_rule\_visibility\_enable\_sampled\_requests) | Whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | `true` | no |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_webacl_description"></a> [webacl\_description](#input\_webacl\_description) | A description for the WebACL. | `string` | `null` | no |
| <a name="input_webacl_name"></a> [webacl\_name](#input\_webacl\_name) | A friendly name for the WebACL. | `string` | n/a | yes |
| <a name="input_xss_match_rule"></a> [xss\_match\_rule](#input\_xss\_match\_rule) | Rule statement that defines a string match search for AWS WAF to apply to web requests. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the WAF WebACL |
| <a name="output_aws_wafv2_web_acl_all"></a> [aws\_wafv2\_web\_acl\_all](#output\_aws\_wafv2\_web\_acl\_all) | Map of all aws\_wafv2\_web\_acl |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_id"></a> [id](#output\_id) | The ID of the WAF WebACL |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->