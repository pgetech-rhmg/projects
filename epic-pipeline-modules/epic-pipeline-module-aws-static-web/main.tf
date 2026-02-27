###############################################################################
# MODULE 1 — TAGS
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id = var.aws_account_id
  environment = var.environment
  appid = var.appid
  compliance = var.compliance
  cris = var.cris
  dataclassification = var.dataclassification
  notify = var.notify
  order = var.order
  owner = var.owner
}

###############################################################################
# MODULE 2 — S3 WEBSITE BUCKET
###############################################################################

module "s3" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-s3.git?ref=main"

  providers = {
    aws = aws.deploy
  }

  app_name                    = var.app_name
  environment                 = var.environment
  tags                        = module.tags.tags
  access_log_bucket           = var.access_log_bucket
  access_log_prefix           = var.access_log_prefix
  custom_bucket_name          = var.custom_bucket_name
  bucket_policy_json          = var.bucket_policy_json
  enable_access_logging       = var.enable_access_logging
  enable_public_access_block  = var.enable_public_access_block
  enable_versioning           = var.enable_versioning
  force_destroy               = var.force_destroy
  kms_key_arn                 = var.kms_key_arn
  lifecycle_rules             = var.lifecycle_rules
  object_ownership            = var.object_ownership
  sse_algorithm               = var.sse_algorithm
}


###############################################################################
# MODULE 3 — CLOUD FRONT DISTRIBUTION
###############################################################################

module "cloudfront" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-cloudfront.git?ref=main"

  providers = {
    aws = aws.deploy
    aws.us_east_1 = aws.us_east_1
  }

  principal_orgid             = var.principal_orgid
  app_name                    = var.app_name
  environment                 = var.environment
  bucket_name                 = module.s3.bucket_name
  bucket_arn                  = module.s3.bucket_arn
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  tags                        = module.tags.tags
  price_class                 = var.price_class
  custom_domain_aliases       = var.custom_domain_aliases
  custom_acm_certificate_arn  = var.custom_acm_certificate_arn
}


###############################################################################
# MODULE 4 — DEPLOYMENT PIPELINE (CODEPIPELINE)
###############################################################################

module "deploy_static_site" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-deploy-static-site.git?ref=main"

  providers = {
    aws = aws.deploy
  }

  app_name                = var.app_name
  bucket_name             = module.s3.bucket_name
  app_path                = var.app_path
  cache_control           = var.cache_control
  content_type_overrides  = var.content_type_overrides
}
