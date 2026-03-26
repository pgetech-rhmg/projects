/*
 * # AWS DataSync s3->fsx_windows module example
*/
#
#  Filename    : modules/datasync/examples/s3_to_fsx_windows/main.tf
#  Date        : 09 May 2024
#  Author      : Eric Barnard (e6bo@pge.com)
#  Description : Create a DataSync task to sync data from an S3 bucket to an FSx for Windows File Server
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

  task_name         = var.task_name
  posix_permissions = var.posix_permissions
  gid               = var.gid
  uid               = var.uid

  source_location_arn      = module.s3_source.arn
  destination_location_arn = module.fsx_destination.arn
  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
  tags                     = module.tags.tags
}

# Create our s3 bucket
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.bucket_name
  tags        = module.tags.tags
}

# Create our source s3 bucket location
module "s3_source" {
  source = "../../modules/s3_location"

  s3_location_arn          = module.s3.arn
  s3_location_subdirectory = var.s3_location_subdirectory
  s3_datasync_access_role  = module.aws_iam_role.arn
  tags                     = module.tags.tags
}

# Create our destination FSx for Windows location
module "fsx_destination" {
  source = "../../modules/fsx_windows_location"

  filesystem_arn      = var.fsx_location_arn
  security_group_arns = ["arn:aws:ec2:us-west-2:514712703977:security-group/sg-01926705cbfb8dcb4"]
  domain              = var.domain
  user                = var.fsx_user
  password            = var.fsx_password
  tags                = module.tags.tags
}

# Create the IAM role for DataSync to access the S3 bucket
module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  aws_service   = var.aws_service
  name          = var.s3_role_name
  inline_policy = [templatefile("${path.module}/s3_kms_policy.json", { bucket_name = var.bucket_name })]
  tags          = module.tags.tags
}