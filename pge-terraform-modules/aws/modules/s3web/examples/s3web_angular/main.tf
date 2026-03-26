locals {
  bucket_name        = var.bucket_name
  r53_aws_role       = var.aws_r53_role
  r53_account_num    = var.account_num_r53
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}

locals {
  d_account_id = data.aws_arn.sts.account
  d_resource   = data.aws_arn.sts.resource
  d_role       = split("/", local.d_resource)[1]
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
#  policy      = data.aws_iam_policy_document.kms_key_policy.json
# }

module "s3web" {
  source = "../.."
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
    aws.r53       = aws.r53
    github        = github
  }
  tags                                 = module.tags.tags
  bucket_name                          = local.bucket_name
  custom_domain_name                   = var.custom_domain_name
  kms_key_arn                          = null # replace with module.kms_key.key_arn, after key creation
  s3web_type                           = var.s3web_type
  cloudfront_priceclass                = var.cloudfront_priceclass
  github_repo_url                      = var.github_repo_url
  github_branch                        = var.github_branch
  secretsmanager_github_token          = var.secretsmanager_github_token
  secretsmanager_artifactory_user      = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token     = var.secretsmanager_artifactory_token
  s3web_cmk_enabled                    = var.s3web_cmk_enabled
  secretsmanager_sonar_token           = var.secretsmanager_sonar_token
  nodejs_version                       = var.nodejs_version
  versioning                           = var.versioning
  object_lock_configuration            = var.object_lock_configuration
  project_key                          = var.project_key
  project_name                         = var.project_name
  cloudfront_oac_name                  = var.cloudfront_oac_name
  cf_function_name                     = var.cf_function_name
  cf_function_comment                  = "rewrite SPA path to default"
  cf_function_publish                  = true
  existing_cloudfront_distribution_arn = var.existing_cloudfront_distribution_arn
  create_route53_records               = var.create_route53_records
}

