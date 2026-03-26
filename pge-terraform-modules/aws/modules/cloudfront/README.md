<!-- BEGIN_TF_DOCS -->
# AWS CloudFront module
Terraform module which creates SAF2.0 CloudFront in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.0.0 |

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
| [aws_cloudfront_distribution.cf_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_monitoring_subscription.cf_monitoring_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_monitoring_subscription) | resource |
| [aws_cloudfront_realtime_log_config.cf_realtime_log_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_realtime_log_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Aliases, or CNAMES, for the distribution | `list(string)` | `null` | no |
| <a name="input_cf_monitoring_subscription"></a> [cf\_monitoring\_subscription](#input\_cf\_monitoring\_subscription) | Creates a monitoring subscription | `any` | `[]` | no |
| <a name="input_cf_realtime_log_config"></a> [cf\_realtime\_log\_config](#input\_cf\_realtime\_log\_config) | Creates a realtime log config | `any` | `[]` | no |
| <a name="input_comment_cfd"></a> [comment\_cfd](#input\_comment\_cfd) | comment for cloudfront distribution | `string` | `null` | no |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | Custom error response to be used for cloudfront distribution. | `any` | `[]` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL | `string` | `null` | no |
| <a name="input_df_cache_behavior_allowed_methods"></a> [df\_cache\_behavior\_allowed\_methods](#input\_df\_cache\_behavior\_allowed\_methods) | Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_cache_policy_id"></a> [df\_cache\_behavior\_cache\_policy\_id](#input\_df\_cache\_behavior\_cache\_policy\_id) | The unique identifier of the cache policy that is attached to the cache behavior. | `string` | `null` | no |
| <a name="input_df_cache_behavior_cached_methods"></a> [df\_cache\_behavior\_cached\_methods](#input\_df\_cache\_behavior\_cached\_methods) | Controls whether CloudFront caches the response to requests using the specified HTTP methods. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_compress"></a> [df\_cache\_behavior\_compress](#input\_df\_cache\_behavior\_compress) | Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false). | `bool` | `false` | no |
| <a name="input_df_cache_behavior_default_ttl"></a> [df\_cache\_behavior\_default\_ttl](#input\_df\_cache\_behavior\_default\_ttl) | The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header. | `number` | `null` | no |
| <a name="input_df_cache_behavior_field_level_encryption_id"></a> [df\_cache\_behavior\_field\_level\_encryption\_id](#input\_df\_cache\_behavior\_field\_level\_encryption\_id) | Field level encryption configuration ID | `string` | `null` | no |
| <a name="input_df_cache_behavior_max_ttl"></a> [df\_cache\_behavior\_max\_ttl](#input\_df\_cache\_behavior\_max\_ttl) | The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. | `number` | `null` | no |
| <a name="input_df_cache_behavior_min_ttl"></a> [df\_cache\_behavior\_min\_ttl](#input\_df\_cache\_behavior\_min\_ttl) | The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds. | `number` | `null` | no |
| <a name="input_df_cache_behavior_origin_request_policy_id"></a> [df\_cache\_behavior\_origin\_request\_policy\_id](#input\_df\_cache\_behavior\_origin\_request\_policy\_id) | The unique identifier of the origin request policy that is attached to the behavior | `string` | `null` | no |
| <a name="input_df_cache_behavior_realtime_log_config_arn"></a> [df\_cache\_behavior\_realtime\_log\_config\_arn](#input\_df\_cache\_behavior\_realtime\_log\_config\_arn) | The ARN of the real-time log configuration that is attached to this cache behavior. | `string` | `null` | no |
| <a name="input_df_cache_behavior_response_headers_policy_id"></a> [df\_cache\_behavior\_response\_headers\_policy\_id](#input\_df\_cache\_behavior\_response\_headers\_policy\_id) | The identifier for a response headers policy. | `string` | `null` | no |
| <a name="input_df_cache_behavior_smooth_streaming"></a> [df\_cache\_behavior\_smooth\_streaming](#input\_df\_cache\_behavior\_smooth\_streaming) | Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior. | `bool` | `null` | no |
| <a name="input_df_cache_behavior_target_origin_id"></a> [df\_cache\_behavior\_target\_origin\_id](#input\_df\_cache\_behavior\_target\_origin\_id) | The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior | `string` | n/a | yes |
| <a name="input_df_cache_behavior_trusted_key_groups"></a> [df\_cache\_behavior\_trusted\_key\_groups](#input\_df\_cache\_behavior\_trusted\_key\_groups) | A list of key group IDs that CloudFront can use to validate signed URLs or signed cookies. | `list(string)` | `null` | no |
| <a name="input_df_cache_behavior_trusted_signers"></a> [df\_cache\_behavior\_trusted\_signers](#input\_df\_cache\_behavior\_trusted\_signers) | List of AWS account IDs (or self) that you want to allow to create signed URLs for private content. | `list(string)` | `null` | no |
| <a name="input_df_cache_behavior_viewer_protocol_policy"></a> [df\_cache\_behavior\_viewer\_protocol\_policy](#input\_df\_cache\_behavior\_viewer\_protocol\_policy) | specifies the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content | `bool` | n/a | yes |
| <a name="input_forwarded_values"></a> [forwarded\_values](#input\_forwarded\_values) | The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers | `any` | `[]` | no |
| <a name="input_function_association"></a> [function\_association](#input\_function\_association) | A config block that triggers a cloudfront function with specific actions | `any` | `[]` | no |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist) | `any` | n/a | yes |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2 | `string` | `"http2"` | no |
| <a name="input_lambda_function_association"></a> [lambda\_function\_association](#input\_lambda\_function\_association) | A config block that triggers a lambda function with specific actions | `any` | `[]` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | The logging configuration that controls how logs are written to your distribution | `any` | n/a | yes |
| <a name="input_ordered_cache_behavior"></a> [ordered\_cache\_behavior](#input\_ordered\_cache\_behavior) | An ordered list of cache behaviors resource for this distribution | `any` | `[]` | no |
| <a name="input_origin"></a> [origin](#input\_origin) | One or more origins for this distribution | `any` | n/a | yes |
| <a name="input_origin_group"></a> [origin\_group](#input\_origin\_group) | One or more origin\_group for this distribution | `any` | `[]` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | The price class of the CloudFront Distribution. Valid types are PriceClass\_All, PriceClass\_100, PriceClass\_200 | `string` | `"PriceClass_100"` | no |
| <a name="input_retain_on_delete"></a> [retain\_on\_delete](#input\_retain\_on\_delete) | Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | The SSL configuration for this distribution | `any` | n/a | yes |
| <a name="input_wait_for_deployment"></a> [wait\_for\_deployment](#input\_wait\_for\_deployment) | If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process. | `bool` | `true` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_all"></a> [cloudfront\_distribution\_all](#output\_cloudfront\_distribution\_all) | Map of all cloudfront\_distribution attributes |
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
| <a name="output_monitoring_subscription_id"></a> [monitoring\_subscription\_id](#output\_monitoring\_subscription\_id) | The ID of the CloudFront monitoring subscription, which corresponds to the distribution\_id. |
| <a name="output_realtime_log_config_arn"></a> [realtime\_log\_config\_arn](#output\_realtime\_log\_config\_arn) | The ARN (Amazon Resource Name) of the CloudFront real-time log configuration. |
| <a name="output_realtime_log_config_id"></a> [realtime\_log\_config\_id](#output\_realtime\_log\_config\_id) | The ID of the CloudFront real-time log configuration. |


<!-- END_TF_DOCS -->