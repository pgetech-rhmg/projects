<!-- BEGIN_TF_DOCS -->
# AWS Lambda@edge module with Cloudfront distribution example. This example is using Cloudfront PGE module.
# Code verified using terraform validate and terraform fmt -check.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_aws.r53"></a> [aws.r53](#provider\_aws.r53) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

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
| <a name="module_acm_public_certificate"></a> [acm\_public\_certificate](#module\_acm\_public\_certificate) | app.terraform.io/pgetech/acm/aws | 0.1.2 |
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | app.terraform.io/pgetech/cloudfront/aws//modules/cloudfront_custom_origin | 0.1.1 |
| <a name="module_cloudfront_oai"></a> [cloudfront\_oai](#module\_cloudfront\_oai) | app.terraform.io/pgetech/cloudfront/aws//modules/origin_access_identity | 0.1.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_lambda_edge_function"></a> [lambda\_edge\_function](#module\_lambda\_edge\_function) | ../../ | n/a |
| <a name="module_records"></a> [records](#module\_records) | app.terraform.io/pgetech/route53/aws | 0.1.1 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_object.index_html](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_pet.ledge](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.lambda_edge_exec_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.private_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

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
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_r53_region"></a> [aws\_r53\_region](#input\_aws\_r53\_region) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name. A unique identifier. | `string` | n/a | yes |
| <a name="input_comment_cf_oai"></a> [comment\_cf\_oai](#input\_comment\_cf\_oai) | comment for origin access identity | `string` | n/a | yes |
| <a name="input_comment_cfd"></a> [comment\_cfd](#input\_comment\_cfd) | comment for cloudfront distribution | `string` | n/a | yes |
| <a name="input_cors_rule_inputs"></a> [cors\_rule\_inputs](#input\_cors\_rule\_inputs) | Map containing static web-site cors configuration. | `any` | `{}` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_custom_error_response"></a> [custom\_error\_response](#input\_custom\_error\_response) | Custom error response to be used for cloudfront distribution. | `any` | n/a | yes |
| <a name="input_custom_header_name"></a> [custom\_header\_name](#input\_custom\_header\_name) | Name of the custom header | `string` | n/a | yes |
| <a name="input_custom_header_value"></a> [custom\_header\_value](#input\_custom\_header\_value) | Value for the custom header | `string` | n/a | yes |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_df_cache_behavior_allowed_methods"></a> [df\_cache\_behavior\_allowed\_methods](#input\_df\_cache\_behavior\_allowed\_methods) | Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_cached_methods"></a> [df\_cache\_behavior\_cached\_methods](#input\_df\_cache\_behavior\_cached\_methods) | Controls whether CloudFront caches the response to requests using the specified HTTP methods. | `list(string)` | n/a | yes |
| <a name="input_df_cache_behavior_viewer_protocol_policy"></a> [df\_cache\_behavior\_viewer\_protocol\_policy](#input\_df\_cache\_behavior\_viewer\_protocol\_policy) | specifies the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content | `bool` | n/a | yes |
| <a name="input_forwarded_values"></a> [forwarded\_values](#input\_forwarded\_values) | The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers | `any` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_geo_restriction"></a> [geo\_restriction](#input\_geo\_restriction) | The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist) | `any` | n/a | yes |
| <a name="input_grants"></a> [grants](#input\_grants) | Map containing configuration. | `any` | `{}` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2 | `string` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS role to assume | `string` | n/a | yes |
| <a name="input_kms_template_file_name"></a> [kms\_template\_file\_name](#input\_kms\_template\_file\_name) | Policy template file in json format | `string` | `""` | no |
| <a name="input_lambda_event_type"></a> [lambda\_event\_type](#input\_lambda\_event\_type) | The specific event to trigger this function. | `string` | n/a | yes |
| <a name="input_lambda_policy_description"></a> [lambda\_policy\_description](#input\_lambda\_policy\_description) | The description of the policy | `string` | `""` | no |
| <a name="input_lambda_policy_name"></a> [lambda\_policy\_name](#input\_lambda\_policy\_name) | The name of the policy | `string` | n/a | yes |
| <a name="input_lambda_policy_path"></a> [lambda\_policy\_path](#input\_lambda\_policy\_path) | The path of the policy in IAM | `string` | `"/"` | no |
| <a name="input_local_zip_source_directory"></a> [local\_zip\_source\_directory](#input\_local\_zip\_source\_directory) | Package entire contents of this directory into the archive | `string` | n/a | yes |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Map containing static web-site configuration. | `any` | `{}` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_origin_shield_enabled"></a> [origin\_shield\_enabled](#input\_origin\_shield\_enabled) | A flag that specifies whether Origin Shield is enabled | `bool` | n/a | yes |
| <a name="input_origin_shield_region"></a> [origin\_shield\_region](#input\_origin\_shield\_region) | The AWS Region for Origin Shield | `string` | n/a | yes |
| <a name="input_policy_arns_list"></a> [policy\_arns\_list](#input\_policy\_arns\_list) | A list of managed IAM policies to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_static_content"></a> [static\_content](#input\_static\_content) | The static content (html, css, etc) to include in the s3 bucket. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
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
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |
| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | Date this resource was last modified |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | ARN identifying your Lambda Function Version (if versioning is enabled via publish = true) |
| <a name="output_lambda_signing_job_arn"></a> [lambda\_signing\_job\_arn](#output\_lambda\_signing\_job\_arn) | ARN of the signing job |
| <a name="output_lambda_signing_profile_version_arn"></a> [lambda\_signing\_profile\_version\_arn](#output\_lambda\_signing\_profile\_version\_arn) | ARN of the signing profile version |
| <a name="output_lambda_source_code_size"></a> [lambda\_source\_code\_size](#output\_lambda\_source\_code\_size) | Size in bytes of the function .zip file |
| <a name="output_lambda_tags_all"></a> [lambda\_tags\_all](#output\_lambda\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of your Lambda Function |
| <a name="output_monitoring_subscription_id"></a> [monitoring\_subscription\_id](#output\_monitoring\_subscription\_id) | The ID of the CloudFront monitoring subscription, which corresponds to the distribution\_id. |
| <a name="output_origin_access_identity_caller_reference"></a> [origin\_access\_identity\_caller\_reference](#output\_origin\_access\_identity\_caller\_reference) | Internal value used by CloudFront to allow future updates to the origin access identity. |
| <a name="output_origin_access_identity_cloudfront_access_identity_path"></a> [origin\_access\_identity\_cloudfront\_access\_identity\_path](#output\_origin\_access\_identity\_cloudfront\_access\_identity\_path) | A shortcut to the full path for the origin access identity to use in CloudFront. |
| <a name="output_origin_access_identity_etag"></a> [origin\_access\_identity\_etag](#output\_origin\_access\_identity\_etag) | The current version of the origin access identity's information. |
| <a name="output_origin_access_identity_iam_arn"></a> [origin\_access\_identity\_iam\_arn](#output\_origin\_access\_identity\_iam\_arn) | A pre-generated ARN for use in S3 bucket policies. |
| <a name="output_origin_access_identity_id"></a> [origin\_access\_identity\_id](#output\_origin\_access\_identity\_id) | The identifier for the distribution. |
| <a name="output_origin_access_identity_s3_canonical_user_id"></a> [origin\_access\_identity\_s3\_canonical\_user\_id](#output\_origin\_access\_identity\_s3\_canonical\_user\_id) | The Amazon S3 canonical user ID for the origin access identity, which you use when giving the origin access identity read permission to an object in Amazon S3. |
| <a name="output_realtime_log_config_arn"></a> [realtime\_log\_config\_arn](#output\_realtime\_log\_config\_arn) | The ARN (Amazon Resource Name) of the CloudFront real-time log configuration. |
| <a name="output_realtime_log_config_id"></a> [realtime\_log\_config\_id](#output\_realtime\_log\_config\_id) | The ID of the CloudFront real-time log configuration. |

<!-- END_TF_DOCS -->