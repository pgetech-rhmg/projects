/*
 * # AWS DataSync s3->s3 module example
*/
#
#  Filename    : modules/datasync/examples/s3_to_s3/main.tf
#  Date        : 09 May 2024
#  Author      : Eric Barnard (e6bo@pge.com)
#  Description : Create a datasync task to sync data from an S3 bucket to another S3 bucket
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

# DataSync task
module "datasync" {
  source = "../../"

  task_name                = var.task_name
  source_location_arn      = module.s3_location[0].arn
  destination_location_arn = module.s3_location[1].arn
  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
  # Since S3 is used, we need to set all POSIX related task options to NONE.
  posix_permissions = var.posix_permissions
  gid               = var.gid
  uid               = var.uid
  tags              = module.tags.tags
}

# Create our s3 buckets
module "s3" {
  count = 2

  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = count.index == 0 ? var.source_bucket_name : var.destination_bucket_name
  tags        = module.tags.tags
}

# Create the source and destination locations
module "s3_location" {
  source = "../../modules/s3_location"
  count  = 2

  s3_location_arn          = module.s3[count.index].arn
  s3_location_subdirectory = count.index == 0 ? var.source_location_subdirectory : var.destination_location_subdirectory
  s3_datasync_access_role  = module.aws_iam_role.arn
  tags                     = module.tags.tags
}

# Create the IAM role for DataSync to access the S3 buckets
module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  aws_service   = var.aws_service
  name          = var.s3_role_name
  inline_policy = [templatefile("${path.module}/s3_kms_policy.json", { source_bucket_name = var.source_bucket_name, destination_bucket_name = var.destination_bucket_name })]
  tags          = module.tags.tags
}