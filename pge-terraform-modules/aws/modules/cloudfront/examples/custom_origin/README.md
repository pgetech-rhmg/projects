<!-- BEGIN_TF_DOCS -->
# AWS CloudFront module Custom Origin example

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
| <a name="provider_aws.east"></a> [aws.east](#provider\_aws.east) | >= 5.0 |

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
| <a name="module_alb"></a> [alb](#module\_alb) | app.terraform.io/pgetech/alb/aws | 0.1.2 |
| <a name="module_alb_security_group"></a> [alb\_security\_group](#module\_alb\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_iam_role_kinesis"></a> [aws\_iam\_role\_kinesis](#module\_aws\_iam\_role\_kinesis) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_s3_bucket"></a> [aws\_s3\_bucket](#module\_aws\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../../modules/cloudfront_custom_origin | n/a |
| <a name="module_cloudfront_function"></a> [cloudfront\_function](#module\_cloudfront\_function) | ../../modules/cloudfront_function | n/a |
| <a name="module_cloudfront_policy"></a> [cloudfront\_policy](#module\_cloudfront\_policy) | ../../modules/cloudfront_policy | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | app.terraform.io/pgetech/ec2/aws | 0.1.2 |
| <a name="module_ec2_security_group"></a> [ec2\_security\_group](#module\_ec2\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_encryption_configurations"></a> [encryption\_configurations](#module\_encryption\_configurations) | ../../modules/field_level_encryption_config | n/a |
| <a name="module_encryption_profiles"></a> [encryption\_profiles](#module\_encryption\_profiles) | ../../modules/field_level_encryption_profile | n/a |
| <a name="module_key_management"></a> [key\_management](#module\_key\_management) | ../../modules/key_management | n/a |
| <a name="module_s3_cf_log_bucket"></a> [s3\_cf\_log\_bucket](#module\_s3\_cf\_log\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_wafv2_web_acl"></a> [wafv2\_web\_acl](#module\_wafv2\_web\_acl) | app.terraform.io/pgetech/waf-v2/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_kinesis_firehose_delivery_stream.extended_s3_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_kinesis_stream.test_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_s3_bucket.bucket_alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.s3_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.s3_alb_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.golden_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb on AWS | `string` | n/a | yes |
| <a name="input_alb_s3_bucket_name"></a> [alb\_s3\_bucket\_name](#input\_alb\_s3\_bucket\_name) | Name of the S3 bucket for alb logs. | `string` | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | Security group for example usage with alb | `string` | n/a | yes |
| <a name="input_alb_sg_name"></a> [alb\_sg\_name](#input\_alb\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_aws_kinesis_firehose_delivery_stream_name"></a> [aws\_kinesis\_firehose\_delivery\_stream\_name](#input\_aws\_kinesis\_firehose\_delivery\_stream\_name) | Name of the aws kinesis firehose delivery stream used for waf v2 logging. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the aws\_accounts variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_bucket_sse_algorithm"></a> [bucket\_sse\_algorithm](#input\_bucket\_sse\_algorithm) | The server-side encryption algorithm to use. | `string` | n/a | yes |
| <a name="input_cache_policy"></a> [cache\_policy](#input\_cache\_policy) | A list of string to provide values for the resource cache policy | `any` | n/a | yes |
| <a name="input_cf_function_name"></a> [cf\_function\_name](#input\_cf\_function\_name) | Unique name for your CloudFront Function | `string` | n/a | yes |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether the associated resource sends metrics to CloudWatch. | `bool` | n/a | yes |
| <a name="input_comment_cfd"></a> [comment\_cfd](#input\_comment\_cfd) | comment for cloudfront distribution | `string` | n/a | yes |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | Custom error response to be used for cloudfront distribution. | `any` | n/a | yes |
| <a name="input_custom_header_name"></a> [custom\_header\_name](#input\_custom\_header\_name) | Name of the custom header | `string` | n/a | yes |
| <a name="input_custom_header_value"></a> [custom\_header\_value](#input\_custom\_header\_value) | Value for the custom header | `string` | n/a | yes |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL | `string` | n/a | yes |
| <a name="input_df_cache_behavior_allowed_methods"></a> [df\_cache\_behavior\_allowed\_methods](#input\_df\_cache\_behavior\_allowed\_methods) | Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_cached_methods"></a> [df\_cache\_behavior\_cached\_methods](#input\_df\_cache\_behavior\_cached\_methods) | Controls whether CloudFront caches the response to requests using the specified HTTP methods. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_target_origin_id"></a> [df\_cache\_behavior\_target\_origin\_id](#input\_df\_cache\_behavior\_target\_origin\_id) | The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior | `string` | n/a | yes |
| <a name="input_df_cache_behavior_viewer_protocol_policy"></a> [df\_cache\_behavior\_viewer\_protocol\_policy](#input\_df\_cache\_behavior\_viewer\_protocol\_policy) | specifies the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. | `string` | n/a | yes |
| <a name="input_ec2_az"></a> [ec2\_az](#input\_ec2\_az) | List of availability zone for ec2 | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | type of the ec2 instance | `string` | n/a | yes |
| <a name="input_ec2_name"></a> [ec2\_name](#input\_ec2\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_ec2_user_data"></a> [ec2\_user\_data](#input\_ec2\_user\_data) | User data for Ec2 instance | `any` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content | `bool` | n/a | yes |
| <a name="input_encryption_config_content_type"></a> [encryption\_config\_content\_type](#input\_encryption\_config\_content\_type) | The content type for a field-level encryption content type-profile mapping | `string` | n/a | yes |
| <a name="input_encryption_config_format"></a> [encryption\_config\_format](#input\_encryption\_config\_format) | The format for a field-level encryption content type-profile mapping | `string` | n/a | yes |
| <a name="input_encryption_config_forward_when_content_type_is_unknown"></a> [encryption\_config\_forward\_when\_content\_type\_is\_unknown](#input\_encryption\_config\_forward\_when\_content\_type\_is\_unknown) | specifies what to do when an unknown content type is provided for the profile | `bool` | n/a | yes |
| <a name="input_encryption_config_forward_when_query_arg_profile_is_unknown"></a> [encryption\_config\_forward\_when\_query\_arg\_profile\_is\_unknown](#input\_encryption\_config\_forward\_when\_query\_arg\_profile\_is\_unknown) | Flag to set if you want a request to be forwarded to the origin even if the profile specified by the field-level encryption query argument, fle-profile, is unknown | `bool` | n/a | yes |
| <a name="input_encryption_profile_items"></a> [encryption\_profile\_items](#input\_encryption\_profile\_items) | The list of field patterns in a field-level encryption content type profile specify the fields that you want to be encrypted | `list(string)` | n/a | yes |
| <a name="input_encryption_profile_name"></a> [encryption\_profile\_name](#input\_encryption\_profile\_name) | The name of the Field Level Encryption Profile | `string` | n/a | yes |
| <a name="input_encryption_profile_provider_id"></a> [encryption\_profile\_provider\_id](#input\_encryption\_profile\_provider\_id) | The provider associated with the public key being used for encryption | `string` | n/a | yes |
| <a name="input_event_type"></a> [event\_type](#input\_event\_type) | The specific event to trigger this function | `string` | n/a | yes |
| <a name="input_forwarded_values"></a> [forwarded\_values](#input\_forwarded\_values) | The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers | `any` | n/a | yes |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist) | `any` | n/a | yes |
| <a name="input_golden_ami_name"></a> [golden\_ami\_name](#input\_golden\_ami\_name) | The name given in the parameter store for the golden ami | `string` | n/a | yes |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2 | `string` | n/a | yes |
| <a name="input_key_group_name"></a> [key\_group\_name](#input\_key\_group\_name) | A name to identify the key group | `string` | n/a | yes |
| <a name="input_kinesis_firehose_delivery_stream_destination"></a> [kinesis\_firehose\_delivery\_stream\_destination](#input\_kinesis\_firehose\_delivery\_stream\_destination) | This is the destination to where the data is delivered. | `string` | n/a | yes |
| <a name="input_kinesis_iam_role_name"></a> [kinesis\_iam\_role\_name](#input\_kinesis\_iam\_role\_name) | Name of the kinesis iam role | `string` | n/a | yes |
| <a name="input_kinesis_stream_mode"></a> [kinesis\_stream\_mode](#input\_kinesis\_stream\_mode) | Specifies the capacity mode of the stream. | `string` | n/a | yes |
| <a name="input_kinesis_stream_name"></a> [kinesis\_stream\_name](#input\_kinesis\_stream\_name) | A name to identify the stream | `string` | n/a | yes |
| <a name="input_kinesis_stream_retention_period"></a> [kinesis\_stream\_retention\_period](#input\_kinesis\_stream\_retention\_period) | Length of time data records are accessible after they are added to the stream | `number` | n/a | yes |
| <a name="input_kinesis_stream_shard_count"></a> [kinesis\_stream\_shard\_count](#input\_kinesis\_stream\_shard\_count) | The number of shards that the stream will use | `number` | n/a | yes |
| <a name="input_kinesis_stream_shard_level_metrics"></a> [kinesis\_stream\_shard\_level\_metrics](#input\_kinesis\_stream\_shard\_level\_metrics) | A list of shard-level CloudWatch metrics which can be enabled for the stream | `list(string)` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | n/a | yes |
| <a name="input_log_bucket_acl"></a> [log\_bucket\_acl](#input\_log\_bucket\_acl) | S3 bucket acl | `string` | n/a | yes |
| <a name="input_log_bucket_name"></a> [log\_bucket\_name](#input\_log\_bucket\_name) | Name of the S3 bucket for the logging | `string` | n/a | yes |
| <a name="input_log_policy"></a> [log\_policy](#input\_log\_policy) | Policy template file in json format | `string` | n/a | yes |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    override_action = string<br>    excluded_rules  = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (\_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example All and Default\_Action. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_origin_https_port"></a> [origin\_https\_port](#input\_origin\_https\_port) | The HTTPS port the custom origin listens on | `number` | n/a | yes |
| <a name="input_origin_id"></a> [origin\_id](#input\_origin\_id) | A unique identifier for the origin | `string` | n/a | yes |
| <a name="input_origin_protocol_policy"></a> [origin\_protocol\_policy](#input\_origin\_protocol\_policy) | The origin protocol policy to apply to your origin | `string` | n/a | yes |
| <a name="input_origin_request_policy"></a> [origin\_request\_policy](#input\_origin\_request\_policy) | A list of string to provide values for the resource request policy. | `any` | n/a | yes |
| <a name="input_origin_shield_enabled"></a> [origin\_shield\_enabled](#input\_origin\_shield\_enabled) | A flag that specifies whether Origin Shield is enabled | `bool` | n/a | yes |
| <a name="input_origin_shield_region"></a> [origin\_shield\_region](#input\_origin\_shield\_region) | The AWS Region for Origin Shield | `string` | n/a | yes |
| <a name="input_origin_ssl_protocols"></a> [origin\_ssl\_protocols](#input\_origin\_ssl\_protocols) | The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS | `list(string)` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy template file in json format | `string` | n/a | yes |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_public_key_comment"></a> [public\_key\_comment](#input\_public\_key\_comment) | An optional comment about the public key | `string` | n/a | yes |
| <a name="input_realtime_log_config_fields"></a> [realtime\_log\_config\_fields](#input\_realtime\_log\_config\_fields) | The fields that are included in each real-time log record | `list(string)` | n/a | yes |
| <a name="input_realtime_log_config_name"></a> [realtime\_log\_config\_name](#input\_realtime\_log\_config\_name) | The unique name to identify this real-time log configuration | `string` | n/a | yes |
| <a name="input_realtime_log_config_sampling_rate"></a> [realtime\_log\_config\_sampling\_rate](#input\_realtime\_log\_config\_sampling\_rate) | The sampling rate for this real-time log configuration | `number` | n/a | yes |
| <a name="input_realtime_log_config_stream_type"></a> [realtime\_log\_config\_stream\_type](#input\_realtime\_log\_config\_stream\_type) | The type of data stream where real-time log data is sent | `string` | n/a | yes |
| <a name="input_realtime_metrics_subscription_status"></a> [realtime\_metrics\_subscription\_status](#input\_realtime\_metrics\_subscription\_status) | A subscription configuration for additional CloudWatch metrics | `string` | n/a | yes |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported. | `any` | n/a | yes |
| <a name="input_request_default_action"></a> [request\_default\_action](#input\_request\_default\_action) | The action to perform if none of the rules contained in the WebACL match. | `string` | n/a | yes |
| <a name="input_response_headers_policy"></a> [response\_headers\_policy](#input\_response\_headers\_policy) | A list of string to provide values for the resource response headers policy | `any` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_sampled_requests_enabled"></a> [sampled\_requests\_enabled](#input\_sampled\_requests\_enabled) | Whether AWS WAF should store a sampling of the web requests that match the rules. | `bool` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Security group for example usage with EC2 | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_subnet_id3_name"></a> [subnet\_id3\_name](#input\_subnet\_id3\_name) | The name given in the parameter store for the subnet id 3 | `string` | n/a | yes |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Name of the target group | `string` | n/a | yes |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| <a name="input_target_group_target_type"></a> [target\_group\_target\_type](#input\_target\_group\_target\_type) | Type of target that you must specify when registering targets with this target group | `string` | n/a | yes |
| <a name="input_targets_port"></a> [targets\_port](#input\_targets\_port) | The port on which targets receive traffic | `string` | n/a | yes |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | The SSL configuration for this distribution | `any` | n/a | yes |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id | `string` | n/a | yes |
| <a name="input_waf_v2_logging_kinesis_s3_bucket_name"></a> [waf\_v2\_logging\_kinesis\_s3\_bucket\_name](#input\_waf\_v2\_logging\_kinesis\_s3\_bucket\_name) | Name of the S3 bucket for kinesis stream to store the waf v2 logs. | `string` | n/a | yes |
| <a name="input_webacl_description"></a> [webacl\_description](#input\_webacl\_description) | A description for the WebACL. | `string` | n/a | yes |
| <a name="input_webacl_name"></a> [webacl\_name](#input\_webacl\_name) | A friendly name of the WebACL. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_policy_etag"></a> [cache\_policy\_etag](#output\_cache\_policy\_etag) | The current version of the cache policy. |
| <a name="output_cache_policy_id"></a> [cache\_policy\_id](#output\_cache\_policy\_id) | The identifier for the cache policy. |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The ARN (Amazon Resource Name) for the distribution. |
| <a name="output_cloudfront_distribution_caller_reference"></a> [cloudfront\_distribution\_caller\_reference](#output\_cloudfront\_distribution\_caller\_reference) | Internal value used by CloudFront to allow future updates to the distribution configuration. |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | The domain name corresponding to the distribution. |
| <a name="output_cloudfront_distribution_etag"></a> [cloudfront\_distribution\_etag](#output\_cloudfront\_distribution\_etag) | The current version of the distribution's information. |
| <a name="output_cloudfront_distribution_hosted_zone_id"></a> [cloudfront\_distribution\_hosted\_zone\_id](#output\_cloudfront\_distribution\_hosted\_zone\_id) | The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID. |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The identifier for the distribution. |
| <a name="output_cloudfront_distribution_in_progress_validation_batches"></a> [cloudfront\_distribution\_in\_progress\_validation\_batches](#output\_cloudfront\_distribution\_in\_progress\_validation\_batches) | The number of invalidation batches currently in progress. |
| <a name="output_cloudfront_distribution_last_modified_time"></a> [cloudfront\_distribution\_last\_modified\_time](#output\_cloudfront\_distribution\_last\_modified\_time) | The date and time the distribution was last modified. |
| <a name="output_cloudfront_distribution_status"></a> [cloudfront\_distribution\_status](#output\_cloudfront\_distribution\_status) | The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system. |
| <a name="output_cloudfront_distribution_tags_all"></a> [cloudfront\_distribution\_tags\_all](#output\_cloudfront\_distribution\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider. |
| <a name="output_cloudfront_distribution_trusted_key_groups"></a> [cloudfront\_distribution\_trusted\_key\_groups](#output\_cloudfront\_distribution\_trusted\_key\_groups) | List of nested attributes for active trusted key groups, if the distribution is set up to serve private content with signed URLs. |
| <a name="output_cloudfront_distribution_trusted_signers"></a> [cloudfront\_distribution\_trusted\_signers](#output\_cloudfront\_distribution\_trusted\_signers) | List of nested attributes for active trusted signers, if the distribution is set up to serve private content with signed URLs. |
| <a name="output_cloudfront_function_arn"></a> [cloudfront\_function\_arn](#output\_cloudfront\_function\_arn) | Amazon Resource Name (ARN) identifying your CloudFront Function. |
| <a name="output_cloudfront_function_etag"></a> [cloudfront\_function\_etag](#output\_cloudfront\_function\_etag) | ETag hash of the function. This is the value for the DEVELOPMENT stage of the function. |
| <a name="output_cloudfront_function_live_stage_etag"></a> [cloudfront\_function\_live\_stage\_etag](#output\_cloudfront\_function\_live\_stage\_etag) | ETag hash of any LIVE stage of the function. |
| <a name="output_cloudfront_function_status"></a> [cloudfront\_function\_status](#output\_cloudfront\_function\_status) | Status of the function. Can be UNPUBLISHED, UNASSOCIATED or ASSOCIATED. |
| <a name="output_field_level_encryption_config_caller_reference"></a> [field\_level\_encryption\_config\_caller\_reference](#output\_field\_level\_encryption\_config\_caller\_reference) | Internal value used by CloudFront to allow future updates to the Field Level Encryption Config. |
| <a name="output_field_level_encryption_config_etag"></a> [field\_level\_encryption\_config\_etag](#output\_field\_level\_encryption\_config\_etag) | The current version of the Field Level Encryption Config. |
| <a name="output_field_level_encryption_config_id"></a> [field\_level\_encryption\_config\_id](#output\_field\_level\_encryption\_config\_id) | The identifier for the Field Level Encryption Config. |
| <a name="output_field_level_encryption_profile_caller_reference"></a> [field\_level\_encryption\_profile\_caller\_reference](#output\_field\_level\_encryption\_profile\_caller\_reference) | Internal value used by CloudFront to allow future updates to the Field Level Encryption Profile. |
| <a name="output_field_level_encryption_profile_etag"></a> [field\_level\_encryption\_profile\_etag](#output\_field\_level\_encryption\_profile\_etag) | The current version of the Field Level Encryption Profile. |
| <a name="output_field_level_encryption_profile_id"></a> [field\_level\_encryption\_profile\_id](#output\_field\_level\_encryption\_profile\_id) | The identifier for the Field Level Encryption Profile. |
| <a name="output_key_group_etag"></a> [key\_group\_etag](#output\_key\_group\_etag) | The identifier for this version of the key group. |
| <a name="output_key_group_id"></a> [key\_group\_id](#output\_key\_group\_id) | The identifier for the key group. |
| <a name="output_monitoring_subscription_id"></a> [monitoring\_subscription\_id](#output\_monitoring\_subscription\_id) | The ID of the CloudFront monitoring subscription, which corresponds to the distribution\_id. |
| <a name="output_origin_request_policy_etag"></a> [origin\_request\_policy\_etag](#output\_origin\_request\_policy\_etag) | The current version of the origin request policy. |
| <a name="output_origin_request_policy_id"></a> [origin\_request\_policy\_id](#output\_origin\_request\_policy\_id) | The identifier for the origin request policy. |
| <a name="output_public_key_caller_reference"></a> [public\_key\_caller\_reference](#output\_public\_key\_caller\_reference) | Internal value used by CloudFront to allow future updates to the public key configuration. |
| <a name="output_public_key_etag"></a> [public\_key\_etag](#output\_public\_key\_etag) | The current version of the public key. |
| <a name="output_public_key_id"></a> [public\_key\_id](#output\_public\_key\_id) | The current version of the public key. |
| <a name="output_realtime_log_config_arn"></a> [realtime\_log\_config\_arn](#output\_realtime\_log\_config\_arn) | The ARN (Amazon Resource Name) of the CloudFront real-time log configuration. |
| <a name="output_realtime_log_config_id"></a> [realtime\_log\_config\_id](#output\_realtime\_log\_config\_id) | The ID of the CloudFront real-time log configuration. |
| <a name="output_response_headers_policy_etag"></a> [response\_headers\_policy\_etag](#output\_response\_headers\_policy\_etag) | The current version of the response headers policy. |
| <a name="output_response_headers_policy_id"></a> [response\_headers\_policy\_id](#output\_response\_headers\_policy\_id) | The identifier for the response headers policy. |


<!-- END_TF_DOCS -->