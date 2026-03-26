/*
 * AWS Backup example - This Example shows how to take backup of an EC2 resource based on Tags assigned to it.
 * Terraform module which creates SAF2.0 AWS Backup resources in AWS
*/

# Filename    : aws/modules/aws-backup/examples/tag-based-selection-backup-ec2-resource/main.tf
# Date        : 30 June 2023
# Author      : PGE
# Description : Manages Tag-based conditions used to specify a set of resources to assign to a backup plan.
#

locals {
  optional_tags   = var.optional_tags
  aws_backup_tags = var.aws_backup_tags
  Order           = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = var.kms_key
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   policy      = file("${path.module}/${var.custom_kms_file}")
#   aws_role    = local.aws_role
#   kms_role    = var.kms_role
# }

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "golden_ami" {
  name = var.golden_ami_name
}

####################################################
# AWS backup Vault
####################################################

module "aws-backup-vault" {
  source = "../../modules/backup-vault/"

  vault_name        = var.vault_name
  vault_kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  ## Comment out vault notification if not required. Default is disabled.
  create_vault_notifications = var.create_vault_notifications
  sns_topic_arn              = aws_sns_topic.sns-topic-backup-notifications.arn
  backup_vault_events        = var.backup_vault_events

  tags = merge(module.tags.tags, local.optional_tags)
}

####################################################
# AWS backup plan
####################################################

module "aws-backup-plan" {
  source = "../../"

  aws_backup_plan_name = var.aws_backup_plan_name
  aws_backup_plan_rule = var.aws_backup_plan_rule

  tags = merge(module.tags.tags, local.optional_tags)

  depends_on = [
    module.aws-backup-vault
  ]
}

####################################################
# Tag based resource selection
####################################################

module "aws-backup-resource-selection" {
  source = "../../modules/backup-resource-selection/"

  backup_selection_name = var.backup_selection_name
  plan_id               = module.aws-backup-plan.backup_plan_id
  selection_tags        = var.selection_tags

  #IAM role
  iam_role_arn = module.aws_iam_role.arn
}



#########################################
# IAM role with AWS-backup service policy
#########################################

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_role_name != null ? var.iam_role_name : "iam-role-${var.backup_selection_name}"
  policy_arns = concat(var.policy_arns_list, ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"])
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
}


########################################################################################################
# Create EBS volume and EC2 - The EC2 shown in this example will be used for backups based on the tags
########################################################################################################

module "ebs" {
  source  = "app.terraform.io/pgetech/ebs/aws"
  version = "0.1.2"

  availability_zone = var.ebs_availability_zone
  size              = var.ebs_size
  type              = var.ebs_type
  kms_key_id        = null # replace with module.kms_key.key_arn, after key creation
  instance_id       = [module.ec2.id]
  device_name       = var.ebs_device_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.security_group.sg_id]

  tags = merge(module.tags.tags, local.optional_tags, local.aws_backup_tags)
}

#########################################
# Create SNS topic and subscription
#########################################
resource "aws_sns_topic" "sns-topic-backup-notifications" {
  name              = var.snstopic_name
  display_name      = var.snstopic_display_name
  kms_master_key_id = null # replace with module.kms_key.key_arn, after key creation
  tags              = merge(module.tags.tags, local.optional_tags)
}

resource "aws_sns_topic_policy" "sns_trigger_lambda" {
  arn = aws_sns_topic.sns-topic-backup-notifications.arn
  policy = templatefile(
    "${path.module}/${var.sns_policy_file_name}",
    {
      snstopic_name = var.snstopic_name
      account_num   = data.aws_caller_identity.current.account_id
      aws_region    = var.aws_region
  })
}

module "sns_topic_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = aws_sns_topic.sns-topic-backup-notifications.arn
}