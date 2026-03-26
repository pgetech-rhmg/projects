<!-- BEGIN_TF_DOCS -->
# AWS s3web module
#### For the latest guide check :  https://wiki.comp.pge.com/display/CCE/Terraform-S3Web
```
# quickstart - steps:
# setup providers
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}
provider "aws" {
  alias  = "r53"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"
  }
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

# invoke the module
module "s3web_html" {
  source  = "app.terraform.io/pgetech/s3web/aws"
  version = "0.1.0"   # update to the latest version as available in terraform registry
  # https://app.terraform.io/app/pgetech/registry/modules/private/pgetech/s3web/aws
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
    aws.r53       = aws.r53
  }
  tags                             = "<REQUIRED-TAGS>"
  bucket_name                      = "<YOUR-BUCKET-NAME>"
  custom_domain_name               = "<YOUR-CUSTOM-DOMAIN-NAME>"
  kms_key_arn                      = "<KMS-KEY-ARN-FOR-CODEPIPELINE>"
  s3web_type                       = "html"
  github_repo_url                  = "<YOUR-GITHUB-REPO-URL>"
  github_branch                    = "<YOUR-GITHUB-BRANCH>"
  secretsmanager_github_token      = "<SECRET-GITHUB-TOKEN-LOCATION>"
  secretsmanager_sonar_token       = "<SECRET-MANAGER-SONAR-TOKEN-LOCATION>"
  project_name                     = "<YOUR-CUSTOM-PROJECT-NAME>"
}
```

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.31.0 |
| <a name="provider_aws.r53"></a> [aws.r53](#provider\_aws.r53) | 6.31.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 6.31.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

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
| <a name="module_cloudfront_origin_access_control"></a> [cloudfront\_origin\_access\_control](#module\_cloudfront\_origin\_access\_control) | app.terraform.io/pgetech/cloudfront/aws//modules/cloudfront_origin_access_control | 0.1.2 |
| <a name="module_codepipeline_angular"></a> [codepipeline\_angular](#module\_codepipeline\_angular) | app.terraform.io/pgetech/codepipeline_s3web/aws//modules/angular | 0.1.4 |
| <a name="module_codepipeline_html"></a> [codepipeline\_html](#module\_codepipeline\_html) | app.terraform.io/pgetech/codepipeline_s3web/aws | 0.1.4 |
| <a name="module_codepipeline_react"></a> [codepipeline\_react](#module\_codepipeline\_react) | app.terraform.io/pgetech/codepipeline_s3web/aws//modules/react | 0.1.4 |
| <a name="module_codepipeline_webhook"></a> [codepipeline\_webhook](#module\_codepipeline\_webhook) | app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook | 0.1.4 |
| <a name="module_external_records"></a> [external\_records](#module\_external\_records) | app.terraform.io/pgetech/route53/aws | 0.1.1 |
| <a name="module_records"></a> [records](#module\_records) | app.terraform.io/pgetech/route53/aws | 0.1.1 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.3 |
| <a name="module_s3_custom_bucket_policy"></a> [s3\_custom\_bucket\_policy](#module\_s3\_custom\_bucket\_policy) | app.terraform.io/pgetech/s3/aws//modules/s3_custom_bucket_policy | 0.1.3 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_wafv2_ip_set"></a> [wafv2\_ip\_set](#module\_wafv2\_ip\_set) | app.terraform.io/pgetech/waf-v2/aws//modules/wafv2_ip_set_cloudfront | 0.1.1 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_request_policy.spa_origin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_s3_object.index_html](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_shield_protection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [random_pet.s3web](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_arn.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_cache_policy.caching_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_distribution.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_distribution) | data source |
| [aws_iam_policy_document.cloudfront_s3_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.private_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.public_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.artifactory_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.artifactory_repo_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.external_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.sonar_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/wafv2_web_acl) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_aws_shield_protection"></a> [advanced\_aws\_shield\_protection](#input\_advanced\_aws\_shield\_protection) | Allow PGE networks in WAF | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name. A unique identifier. | `string` | `null` | no |
| <a name="input_build_args1"></a> [build\_args1](#input\_build\_args1) | Provide the build environment variables required for codebuild | `string` | `""` | no |
| <a name="input_cf_function_code"></a> [cf\_function\_code](#input\_cf\_function\_code) | Source code of the function | `string` | `null` | no |
| <a name="input_cf_function_comment"></a> [cf\_function\_comment](#input\_cf\_function\_comment) | Comment for cloudfront function | `string` | `null` | no |
| <a name="input_cf_function_name"></a> [cf\_function\_name](#input\_cf\_function\_name) | Unique name for your CloudFront Function | `string` | `null` | no |
| <a name="input_cf_function_publish"></a> [cf\_function\_publish](#input\_cf\_function\_publish) | Whether to publish creation/change as Live CloudFront Function Version. | `bool` | `false` | no |
| <a name="input_cf_function_runtime"></a> [cf\_function\_runtime](#input\_cf\_function\_runtime) | The runtime environment for the CloudFront function | `string` | `"cloudfront-js-1.0"` | no |
| <a name="input_cf_log_bucket"></a> [cf\_log\_bucket](#input\_cf\_log\_bucket) | S3 bucket name for CloudFront logs. A unique identifier. | `string` | `null` | no |
| <a name="input_cf_log_prefix"></a> [cf\_log\_prefix](#input\_cf\_log\_prefix) | S3 bucket prefix for CloudFront logs. A unique identifier. | `string` | `null` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | variables for security\_group\_project | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "CCOE egress rules",<br>    "from": 0,<br>    "ipv6_cidr_blocks": [],<br>    "prefix_list_ids": [],<br>    "protocol": "-1",<br>    "to": 0<br>  }<br>]</pre> | no |
| <a name="input_cloudfront_oac_description"></a> [cloudfront\_oac\_description](#input\_cloudfront\_oac\_description) | The description of the Origin Access Control. | `string` | `"Managed by Terraform"` | no |
| <a name="input_cloudfront_oac_name"></a> [cloudfront\_oac\_name](#input\_cloudfront\_oac\_name) | A name that identifies the Origin Access Control. | `string` | n/a | yes |
| <a name="input_cloudfront_oac_origin_type"></a> [cloudfront\_oac\_origin\_type](#input\_cloudfront\_oac\_origin\_type) | The type of origin for this Origin Access Control. Valid values: lambda, mediapackagev2, mediastore, s3. | `string` | `"s3"` | no |
| <a name="input_cloudfront_oac_signing_behavior"></a> [cloudfront\_oac\_signing\_behavior](#input\_cloudfront\_oac\_signing\_behavior) | Specifies which requests CloudFront signs. Allowed values: always, never, no-override. | `string` | `"always"` | no |
| <a name="input_cloudfront_oac_signing_protocol"></a> [cloudfront\_oac\_signing\_protocol](#input\_cloudfront\_oac\_signing\_protocol) | Determines how CloudFront signs requests. The only valid value is sigv4. | `string` | `"sigv4"` | no |
| <a name="input_cloudfront_priceclass"></a> [cloudfront\_priceclass](#input\_cloudfront\_priceclass) | Choosing the price class for a CloudFront distribution | `string` | `"PriceClass_100"` | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | `null` | no |
| <a name="input_cors_rule_inputs"></a> [cors\_rule\_inputs](#input\_cors\_rule\_inputs) | Map containing static web-site cors configuration. | `any` | `[]` | no |
| <a name="input_create_route53_records"></a> [create\_route53\_records](#input\_create\_route53\_records) | Whether to create Route53 records for the custom domain. Set to false when using F5 or other external routing mechanisms. | `bool` | `true` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_custom_error_handlers"></a> [custom\_error\_handlers](#input\_custom\_error\_handlers) | List of cloudfront custom error response handlers | <pre>list(object({<br>    error_code            = number<br>    response_code         = number<br>    response_page_path    = string<br>    error_caching_min_ttl = number<br>  }))</pre> | `[]` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | default root object for cloudfront | `string` | `"index.html"` | no |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of environment variables required for codebuild stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codepublish_stage"></a> [environment\_variables\_codepublish\_stage](#input\_environment\_variables\_codepublish\_stage) | Provide the list of environment variables required for codepublish stage | `list(any)` | `[]` | no |
| <a name="input_environment_variables_codescan_stage"></a> [environment\_variables\_codescan\_stage](#input\_environment\_variables\_codescan\_stage) | Provide the list of environment variables required for codescan stage | `list(any)` | `[]` | no |
| <a name="input_existing_cloudfront_distribution_arn"></a> [existing\_cloudfront\_distribution\_arn](#input\_existing\_cloudfront\_distribution\_arn) | ARN of an existing CloudFront distribution to use instead of creating a new one. If provided, the module will not create a new CloudFront distribution. | `string` | `null` | no |
| <a name="input_function_association"></a> [function\_association](#input\_function\_association) | A config block that triggers a cloudfront function with specific actions | `any` | `[]` | no |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | Enter the value of github repo branch | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | Enter the github repo url for environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_grants"></a> [grants](#input\_grants) | Map containing configuration. | `any` | <pre>[<br>  {<br>    "id": null,<br>    "permissions": [<br>      "READ"<br>    ],<br>    "type": "Group",<br>    "uri": "http://acs.amazonaws.com/groups/s3/LogDelivery"<br>  },<br>  {<br>    "id": null,<br>    "permissions": [<br>      "WRITE"<br>    ],<br>    "type": "Group",<br>    "uri": "http://acs.amazonaws.com/groups/s3/LogDelivery"<br>  }<br>]</pre> | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key arn for S3 bucket and codepipeline encryption | `string` | `null` | no |
| <a name="input_nodejs_version"></a> [nodejs\_version](#input\_nodejs\_version) | Enter the nodejs version value | `string` | `"18"` | no |
| <a name="input_nodejs_version_codescan"></a> [nodejs\_version\_codescan](#input\_nodejs\_version\_codescan) | Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended | `string` | `"20"` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Map containing static web-site configuration. | `any` | `null` | no |
| <a name="input_origin_ssl_protocols"></a> [origin\_ssl\_protocols](#input\_origin\_ssl\_protocols) | The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS. | `list(string)` | <pre>[<br>  "TLSv1",<br>  "TLSv1.1",<br>  "TLSv1.2"<br>]</pre> | no |
| <a name="input_package_manager"></a> [package\_manager](#input\_package\_manager) | Valid values for package manager are (npm, yarn) | `string` | `"npm"` | no |
| <a name="input_pollchanges"></a> [pollchanges](#input\_pollchanges) | Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook | `string` | `"false"` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_root_directory"></a> [project\_root\_directory](#input\_project\_root\_directory) | Enter the project root directory value stored in ssm paramter | `string` | `"."` | no |
| <a name="input_project_unit_test_dir"></a> [project\_unit\_test\_dir](#input\_project\_unit\_test\_dir) | Enter the name of project unit test directory | `string` | `"."` | no |
| <a name="input_s3_log_bucket"></a> [s3\_log\_bucket](#input\_s3\_log\_bucket) | S3 bucket ARN for S3 logs. A unique identifier. | `string` | `null` | no |
| <a name="input_s3_log_prefix"></a> [s3\_log\_prefix](#input\_s3\_log\_prefix) | S3 bucket prefix for S3 logs. A unique identifier. | `string` | `null` | no |
| <a name="input_s3web_cmk_enabled"></a> [s3web\_cmk\_enabled](#input\_s3web\_cmk\_enabled) | is s3web using kms cmk ? | `bool` | `false` | no |
| <a name="input_s3web_pge_waf"></a> [s3web\_pge\_waf](#input\_s3web\_pge\_waf) | WAF type: Valid values are 'internal', 'external' | `string` | `"internal"` | no |
| <a name="input_s3web_type"></a> [s3web\_type](#input\_s3web\_type) | Valid values for s3web type are (html, angular, react, custom) | `string` | `"html"` | no |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | Enter the name of jfrog artifactory token stored in secrets manager | `string` | `"jfrog:token"` | no |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | Enter the name of jfrog artifactory user stored in secrets manager | `string` | `"jfrog:user"` | no |
| <a name="input_secretsmanager_github_token"></a> [secretsmanager\_github\_token](#input\_secretsmanager\_github\_token) | Secret manager path of the github OAUTH or PAT.  Example:  'github:token' | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token value of SonarQube stored in secrets manager | `string` | `"sonar:token"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | `null` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | `null` | no |
| <a name="input_ssm_parameter_artifactory_host"></a> [ssm\_parameter\_artifactory\_host](#input\_ssm\_parameter\_artifactory\_host) | Enter the name of jfrog artifactory host stored in ssm parameter | `string` | `"/jfrog/host"` | no |
| <a name="input_ssm_parameter_artifactory_repo_key"></a> [ssm\_parameter\_artifactory\_repo\_key](#input\_ssm\_parameter\_artifactory\_repo\_key) | Enter the name of JFrog npm Artifactory repo key to use in Terraform CodePipeline to pull the npm dependencies | `string` | `"/jfrog/repo_key"` | no |
| <a name="input_ssm_parameter_external_waf_name"></a> [ssm\_parameter\_external\_waf\_name](#input\_ssm\_parameter\_external\_waf\_name) | Enter the parameter store path for the external WAF Name to use in cloudfront | `string` | `"/waf/external_waf_name"` | no |
| <a name="input_ssm_parameter_sonar_host"></a> [ssm\_parameter\_sonar\_host](#input\_ssm\_parameter\_sonar\_host) | Enter the host value of SonarQube stored in ssm parameter | `string` | `"/sonar/host"` | no |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id\_1 stored in ssm parameter | `string` | `"/vpc/privatesubnet1/id"` | no |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id\_2 stored in ssm parameter | `string` | `"/vpc/privatesubnet2/id"` | no |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id\_3 stored in ssm parameter | `string` | `"/vpc/privatesubnet3/id"` | no |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | `"/vpc/id"` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | A set of domains the should be SANs in the issued certificate. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional resource tags | `map(string)` | n/a | yes |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned. | `string` | `"Disabled"` | no |
| <a name="input_waf_log_bucket"></a> [waf\_log\_bucket](#input\_waf\_log\_bucket) | S3 bucket name for WAF logs. A unique identifier. | `string` | `null` | no |
| <a name="input_wafv2_ip_set_description"></a> [wafv2\_ip\_set\_description](#input\_wafv2\_ip\_set\_description) | A description of the IP set | `string` | `"AWS WAF PGE SourceIP Rule Set"` | no |
| <a name="input_wafv2_ip_set_name"></a> [wafv2\_ip\_set\_name](#input\_wafv2\_ip\_set\_name) | IP set name. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | acm certificate ARN |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The ARN (Amazon Resource Name) for the distribution. |
| <a name="output_cloudfront_distribution_caller_reference"></a> [cloudfront\_distribution\_caller\_reference](#output\_cloudfront\_distribution\_caller\_reference) | Internal value used by CloudFront to allow future updates to the distribution configuration. |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | The domain name corresponding to the distribution. |
| <a name="output_cloudfront_distribution_etag"></a> [cloudfront\_distribution\_etag](#output\_cloudfront\_distribution\_etag) | The current version of the distribution's information. |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The identifier for the distribution. |
| <a name="output_cloudfront_distribution_in_progress_validation_batches"></a> [cloudfront\_distribution\_in\_progress\_validation\_batches](#output\_cloudfront\_distribution\_in\_progress\_validation\_batches) | The number of invalidation batches currently in progress. |
| <a name="output_cloudfront_distribution_last_modified_time"></a> [cloudfront\_distribution\_last\_modified\_time](#output\_cloudfront\_distribution\_last\_modified\_time) | The date and time the distribution was last modified. |
| <a name="output_cloudfront_distribution_status"></a> [cloudfront\_distribution\_status](#output\_cloudfront\_distribution\_status) | The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system. |
| <a name="output_cloudfront_distribution_tags_all"></a> [cloudfront\_distribution\_tags\_all](#output\_cloudfront\_distribution\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider. |
| <a name="output_codepipeline_angular_arn"></a> [codepipeline\_angular\_arn](#output\_codepipeline\_angular\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_html_arn"></a> [codepipeline\_html\_arn](#output\_codepipeline\_html\_arn) | The codepipeline ARN |
| <a name="output_codepipeline_react_arn"></a> [codepipeline\_react\_arn](#output\_codepipeline\_react\_arn) | The codepipeline ARN |
| <a name="output_custom_domain_name"></a> [custom\_domain\_name](#output\_custom\_domain\_name) | alternate domain name for cloudfront distribution |
| <a name="output_github_branch"></a> [github\_branch](#output\_github\_branch) | alternate domain name for cloudfront distribution |
| <a name="output_github_repo_url"></a> [github\_repo\_url](#output\_github\_repo\_url) | alternate domain name for cloudfront distribution |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | s3 ARN. Will be of format arn:aws:s3:::bucketname |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | s3 bucket name |
| <a name="output_s3web_all"></a> [s3web\_all](#output\_s3web\_all) | List of Maps of resources created by the s3web module |
| <a name="output_s3web_type"></a> [s3web\_type](#output\_s3web\_type) | s3web\_type for the codepipeline |
| <a name="output_website_address"></a> [website\_address](#output\_website\_address) | alternate domain name for cloudfront distribution |


<!-- END_TF_DOCS -->