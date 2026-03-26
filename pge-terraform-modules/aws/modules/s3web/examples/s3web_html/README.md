<!-- BEGIN_TF_DOCS -->
# AWS s3web module
#### For the latest guide check :  https://wiki.comp.pge.com/display/CCE/Terraform-S3Web
```
# Quickstart

# Setup the providers
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

# Invoke the module - this is a minimum working implementation
module "s3web" {
  source  = "app.terraform.io/pgetech/s3web/aws"
  version = "0.1.0"   # update to the latest version as available in terraform registry

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
    aws.r53       = aws.r53
  }

  tags                             = "<REQUIRED-TAGS>"
  custom_domain_name               = "<YOUR-CUSTOM-DOMAIN-NAME>"
  github_repo_url                  = "<YOUR-GITHUB-REPO-URL>"
  github_branch                    = "<YOUR-GITHUB-BRANCH>"
  secretsmanager_github_token      = "<SECRET-GITHUB-TOKEN-LOCATION>"
  project_name                     = "<PROJECT-NAME-FOR-SONAR>"
  project_key                      = "<PROJECT-KEY-FOR-SONAR>"

  # Optional: Use existing CloudFront distribution instead of creating new one
  # existing_cloudfront_distribution_arn = "arn:aws:cloudfront::123456789012:distribution/ABCD1234EFGH"
}
```

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

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
| <a name="module_s3web_html"></a> [s3web\_html](#module\_s3web\_html) | ../.. | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_arn.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_r53_region"></a> [aws\_r53\_region](#input\_aws\_r53\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_name_html"></a> [bucket\_name\_html](#input\_bucket\_name\_html) | S3 bucket name. A unique identifier. | `string` | `null` | no |
| <a name="input_build_args1"></a> [build\_args1](#input\_build\_args1) | Provide the list of build environment variables required for codebuild | `string` | `""` | no |
| <a name="input_cloudfront_oac_description"></a> [cloudfront\_oac\_description](#input\_cloudfront\_oac\_description) | The description of the Origin Access Control. | `string` | `"Managed by Terraform"` | no |
| <a name="input_cloudfront_oac_name"></a> [cloudfront\_oac\_name](#input\_cloudfront\_oac\_name) | A name that identifies the Origin Access Control. | `string` | n/a | yes |
| <a name="input_cloudfront_oac_origin_type"></a> [cloudfront\_oac\_origin\_type](#input\_cloudfront\_oac\_origin\_type) | The type of origin for this Origin Access Control. Valid values: lambda, mediapackagev2, mediastore, s3. | `string` | `"s3"` | no |
| <a name="input_cloudfront_oac_signing_behavior"></a> [cloudfront\_oac\_signing\_behavior](#input\_cloudfront\_oac\_signing\_behavior) | Specifies which requests CloudFront signs. Allowed values: always, never, no-override. | `string` | `"always"` | no |
| <a name="input_cloudfront_oac_signing_protocol"></a> [cloudfront\_oac\_signing\_protocol](#input\_cloudfront\_oac\_signing\_protocol) | Determines how CloudFront signs requests. The only valid value is sigv4. | `string` | `"sigv4"` | no |
| <a name="input_cloudfront_priceclass"></a> [cloudfront\_priceclass](#input\_cloudfront\_priceclass) | Choosing the price class for a CloudFront distribution | `string` | `"PriceClass_100"` | no |
| <a name="input_create_route53_records"></a> [create\_route53\_records](#input\_create\_route53\_records) | Whether to create Route53 records for the custom domain. Set to false when using F5 or other external routing mechanisms. | `bool` | `true` | no |
| <a name="input_custom_domain_name_html"></a> [custom\_domain\_name\_html](#input\_custom\_domain\_name\_html) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_existing_cloudfront_distribution_arn"></a> [existing\_cloudfront\_distribution\_arn](#input\_existing\_cloudfront\_distribution\_arn) | ARN of an existing CloudFront distribution to use instead of creating a new one. If provided, the module will not create a new CloudFront distribution. Example: 'arn:aws:cloudfront::123456789012:distribution/ABCD1234EFGH' | `string` | `null` | no |
| <a name="input_github_branch_html"></a> [github\_branch\_html](#input\_github\_branch\_html) | Enter the value of github repo branch | `string` | n/a | yes |
| <a name="input_github_repo_url_html"></a> [github\_repo\_url\_html](#input\_github\_repo\_url\_html) | Enter the github repo url for environment variable used in buildspec yml | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | Description of the KMS key. | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Name of the KMS key. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | With S3 Object Lock, you can store objects using a write-once-read-many (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely. | `any` | `null` | no |
| <a name="input_project_key"></a> [project\_key](#input\_project\_key) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_key_html"></a> [project\_key\_html](#input\_project\_key\_html) | A unique identifier of your project inside SonarQube | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_project_name_html"></a> [project\_name\_html](#input\_project\_name\_html) | The display name visible in SonarQube dashboard. Example: My Project | `string` | n/a | yes |
| <a name="input_s3web_type_html"></a> [s3web\_type\_html](#input\_s3web\_type\_html) | vpc id for security group | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_token"></a> [secretsmanager\_artifactory\_token](#input\_secretsmanager\_artifactory\_token) | secret manager path of the artifactory user token | `string` | n/a | yes |
| <a name="input_secretsmanager_artifactory_user"></a> [secretsmanager\_artifactory\_user](#input\_secretsmanager\_artifactory\_user) | secret manager path of the artifactory user | `string` | n/a | yes |
| <a name="input_secretsmanager_github_token"></a> [secretsmanager\_github\_token](#input\_secretsmanager\_github\_token) | secret manager path of the github OAUTH or PAT | `string` | n/a | yes |
| <a name="input_secretsmanager_sonar_token"></a> [secretsmanager\_sonar\_token](#input\_secretsmanager\_sonar\_token) | Enter the token value of SonarQube stored in secrets manager | `string` | n/a | yes |
| <a name="input_ssm_parameter_artifactory_host"></a> [ssm\_parameter\_artifactory\_host](#input\_ssm\_parameter\_artifactory\_host) | Enter the name of jfrog artifactory host stored in ssm parameter | `string` | `"/jfrog/host"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned. | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | acm certificate ARN |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The identifier for the distribution. |
| <a name="output_codepipeline_html_arn"></a> [codepipeline\_html\_arn](#output\_codepipeline\_html\_arn) | The codepipeline ARN |
| <a name="output_github_branch"></a> [github\_branch](#output\_github\_branch) | alternate domain name for cloudfront distribution |
| <a name="output_github_repo_url"></a> [github\_repo\_url](#output\_github\_repo\_url) | alternate domain name for cloudfront distribution |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | s3 bucket name |
| <a name="output_s3web_type"></a> [s3web\_type](#output\_s3web\_type) | s3web\_type for the codepipeline |
| <a name="output_website_address"></a> [website\_address](#output\_website\_address) | alternate domain name for cloudfront distribution |


<!-- END_TF_DOCS -->