<!-- BEGIN_TF_DOCS -->
# AWS WEB ACL Cloudfront module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.east"></a> [aws.east](#provider\_aws.east) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

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
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_wafv2_ip_set"></a> [wafv2\_ip\_set](#module\_wafv2\_ip\_set) | ../../modules/wafv2_ip_set_cloudfront | n/a |
| <a name="module_wafv2_web_acl"></a> [wafv2\_web\_acl](#module\_wafv2\_web\_acl) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kinesis_firehose_delivery_stream.extended_s3_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_kinesis_firehose_delivery_stream_name"></a> [aws\_kinesis\_firehose\_delivery\_stream\_name](#input\_aws\_kinesis\_firehose\_delivery\_stream\_name) | The name for the kinesis firehose delivery stream. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for resource creation. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the aws\_accounts variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | A boolean indicating whether the associated resource sends metrics to CloudWatch | `bool` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | `"Paramter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | KMS key name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | n/a | yes |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    override_action = string<br>    excluded_rules  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (\_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF for example All and Default\_Action. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `any` | n/a | yes |
| <a name="input_request_default_action"></a> [request\_default\_action](#input\_request\_default\_action) | The action to perform if none of the rules contained in the WebACL match. | `string` | n/a | yes |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | n/a | yes |
| <a name="input_wafv2_ip_set_addresses"></a> [wafv2\_ip\_set\_addresses](#input\_wafv2\_ip\_set\_addresses) | Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6. | `list(string)` | n/a | yes |
| <a name="input_wafv2_ip_set_description"></a> [wafv2\_ip\_set\_description](#input\_wafv2\_ip\_set\_description) | A friendly description of the IP set.. | `string` | n/a | yes |
| <a name="input_wafv2_ip_set_ip_address_version"></a> [wafv2\_ip\_set\_ip\_address\_version](#input\_wafv2\_ip\_set\_ip\_address\_version) | Specify IPV4 or IPV6. Valid values are IPV4 or IPV6. | `string` | n/a | yes |
| <a name="input_webacl_description"></a> [webacl\_description](#input\_webacl\_description) | A description for the WebACL. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the WAF WebACL |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL |
| <a name="output_id"></a> [id](#output\_id) | The ID of the WAF WebACL |
| <a name="output_ip_set_arn"></a> [ip\_set\_arn](#output\_ip\_set\_arn) | The Amazon Resource Name (ARN) that identifies the cluster. |
| <a name="output_ip_set_id"></a> [ip\_set\_id](#output\_ip\_set\_id) | A unique identifier for the set. |
| <a name="output_ip_set_tags_all"></a> [ip\_set\_tags\_all](#output\_ip\_set\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->