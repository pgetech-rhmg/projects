<!-- BEGIN_TF_DOCS -->
# AWS API Gateway deployment and stage module using OpenApi
Terraform module which creates SAF2.0 API Gateway deployment and stage using OpenApi approch in AWS

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
| <a name="module_wafv2_web_acl"></a> [wafv2\_web\_acl](#module\_wafv2\_web\_acl) | app.terraform.io/pgetech/waf-v2/aws//modules/wafv2_web_acl_regional | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl_association.waf2_web_acl_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_stage_arn"></a> [api\_gateway\_stage\_arn](#input\_api\_gateway\_stage\_arn) | The Amazon Resource Name (ARN) for API Gateway Stage | `string` | n/a | yes |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | A boolean indicating whether the associated resource sends metrics to CloudWatch | `bool` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | conetent value | `string` | `"abcdefg"` | no |
| <a name="input_content_type"></a> [content\_type](#input\_content\_type) | content\_type value | `string` | `"TEXT_PLAIN"` | no |
| <a name="input_custom_response_body"></a> [custom\_response\_body](#input\_custom\_response\_body) | key:<br/> Unique key identifying the custom response body. This is referenced by the custom\_response\_body\_key argument in the Custom Response block.<br/> content:<br/> Payload of the custom response.<br/>content\_type:<br/> Type of content in the payload that you are defining in the content argument. Valid values are TEXT\_PLAIN, TEXT\_HTML, or APPLICATION\_JSON. | <pre>list(object({<br/>    key          = string<br/>    content      = string<br/>    content_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_waf"></a> [enable\_waf](#input\_enable\_waf) | to enable during deployment Stage | `bool` | `true` | no |
| <a name="input_key"></a> [key](#input\_key) | this is to define key value | `string` | `"sample"` | no |
| <a name="input_log_destination_arn"></a> [log\_destination\_arn](#input\_log\_destination\_arn) | arn for capturing logs from WebACL. | `string` | n/a | yes |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | `{}` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. For more details refer matching version of the document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#rules. | <pre>list(object({<br/>    name            = string<br/>    priority        = number<br/>    override_action = string<br/>    excluded_rules  = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (\_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF for example All and Default\_Action. | `string` | n/a | yes |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `any` | `[]` | no |
| <a name="input_request_default_action"></a> [request\_default\_action](#input\_request\_default\_action) | The action to perform if none of the rules contained in the WebACL match. | `string` | n/a | yes |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_web_acl_name"></a> [web\_acl\_name](#input\_web\_acl\_name) | The name of the stage | `string` | n/a | yes |
| <a name="input_webacl_description"></a> [webacl\_description](#input\_webacl\_description) | A description for the WebACL. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_capacity"></a> [capacity](#output\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_id"></a> [id](#output\_id) | The ID of the WAF WebACL |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ID for API Gateway Deployment |

<!-- END_TF_DOCS -->