/*
 * # AWS Kinesis firehose  User module example
*/
#
#  Filename    : aws/modules/kinesis-firehose/examples/redshift_destination/main.tf
#  Date        : 22 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates a kinesis firehose 

locals {
  common_name       = "${var.name}-${random_string.name.result}"
  kms_custom_policy = templatefile("${path.module}/kms_policy.json", { account_num = data.aws_caller_identity.current.account_id, role_name = var.aws_role })
  iam_policy = templatefile(
    "${path.module}/kinesis_firehose_iam_policy.json",
    {
      account_num = var.account_num,
      aws_region  = var.aws_region
  })
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.common_name
  aws_role = var.aws_role
  kms_role = var.kms_role
  policy   = local.kms_custom_policy
  tags     = merge(module.tags.tags, var.optional_tags)
}

data "aws_caller_identity" "current" {}

# Supporting Resource
data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_subnet" "redshift_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "redshift_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "redshift_3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

resource "random_password" "redshift_password" {
  length           = 16
  special          = true
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
  upper   = false
}

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
  Order              = var.Order
}

###########################################################################################
# Kinesis firehose - redshift destination
###########################################################################################

module "redshift_firehose" {
  source = "../../"

  depends_on  = [time_sleep.wait]
  name        = local.common_name
  destination = "redshift"

  kinesis_source_server_side_encryption = {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn           = var.kinesis_stream_role_arn
    key_arn            = module.kms_key.key_arn
  }



  redshift_configuration = {
    cluster_jdbcurl = "jdbc:redshift://${module.cluster.cluster_endpoint}/${module.cluster.cluster_database_name}"
    username        = random_password.redshift_password.result
    password        = "aws${random_string.name.result}"
    role_arn        = module.firehose_aws_iam_role.arn
    data_table_name = "example_table"

    retry_duration     = var.retry_duration
    copy_options       = var.copy_options
    data_table_columns = var.data_table_columns
    log_group_name     = module.log_group.cloudwatch_log_group_name
    log_stream_name    = var.redshift_log_stream_name

    s3_backup_mode = var.s3_backup_mode

    s3_backup_role_arn            = module.firehose_aws_iam_role.arn
    s3_backup_bucket_arn          = module.s3.arn
    s3_backup_kms_key_arn         = module.kms_key.key_arn
    s3_backup_prefix              = var.s3_backup_prefix
    s3_backup_buffer_size         = var.s3_backup_buffer_size
    s3_backup_buffer_interval     = var.s3_backup_buffer_interval
    s3_backup_compression_format  = var.s3_backup_compression_format
    s3_backup_error_output_prefix = var.s3_backup_error_output_prefix
    s3_backup_log_group_name      = module.log_group.cloudwatch_log_group_name
    s3_backup_log_stream_name     = var.s3_backup_log_stream_name

    s3_configuration = {
      role_arn    = module.firehose_aws_iam_role.arn
      bucket_arn  = module.s3.arn
      kms_key_arn = module.kms_key.key_arn

      prefix              = var.prefix
      buffer_size         = var.s3_buffer_size
      buffer_interval     = var.s3_buffer_interval
      compression_format  = var.compression_format
      error_output_prefix = var.error_output_prefix
      log_group_name      = module.log_group.cloudwatch_log_group_name
      log_stream_name     = var.s3_log_stream_name
    }

    processing_configuration = {
      enabled    = var.processing_configuration_enabled,
      processors = var.processing_configuration_processors
    }
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

module "firehose_iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name   = local.common_name
  path   = var.path
  policy = [local.iam_policy]
  tags   = merge(module.tags.tags, var.optional_tags)
}

module "firehose_aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.common_name
  aws_service = var.aws_service
  #  Customer Managed Policy
  policy_arns = [module.firehose_iam_policy.arn]
  tags        = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.firehose_iam_policy
  ]

}


module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name_prefix = local.common_name
  tags        = merge(module.tags.tags, var.optional_tags)
}

# log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = var.s3_log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

# log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "redshift_log_stream" {
  name           = var.redshift_log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

# log stream module feature is not available in cloudwatch module, hence using resource to cretae log stream
resource "aws_cloudwatch_log_stream" "s3_backup_log_stream" {
  name           = var.s3_backup_log_stream_name
  log_group_name = module.log_group.cloudwatch_log_group_name
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.common_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.template_file.s3_custom_bucket_policy.rendered
  tags        = merge(module.tags.tags, var.optional_tags)
}

data "template_file" "s3_custom_bucket_policy" {
  template = file("${path.module}/s3_bucket_user_policy.json")
  vars = { bucket_name = local.common_name,
    account_num = var.account_num
  }
}

###########################
# redshift module
###########################

module "cluster" {
  source  = "app.terraform.io/pgetech/redshift/aws"
  version = "0.1.1"

  cluster_identifier        = local.common_name
  master_password           = random_password.redshift_password.result
  master_username           = "aws${random_string.name.result}"
  node_type                 = var.node_type
  cluster_type              = var.cluster_type
  database_name             = var.database_name
  cluster_subnet_group_name = module.redshift_subnet_group.redshift_subnet_group_id
  skip_final_snapshot       = var.skip_final_snapshot
  vpc_security_group_ids    = [module.security_group_redshift.sg_id]
  s3_key_prefix             = var.s3_key_prefix
  kms_key_id                = null # replace with module.kms_key.key_arn, after key creation

  tags = merge(module.tags.tags, var.optional_tags)
}

module "redshift_subnet_group" {
  source  = "app.terraform.io/pgetech/redshift/aws//modules/subnet_group"
  version = "0.1.1"

  subnet_group_name = local.common_name
  subnet_ids        = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags              = merge(module.tags.tags, var.optional_tags)
}

module "security_group_redshift" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.common_name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.redshift_1.cidr_block, data.aws_subnet.redshift_2.cidr_block, data.aws_subnet.redshift_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.redshift_1.cidr_block, data.aws_subnet.redshift_2.cidr_block, data.aws_subnet.redshift_3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

# Time sleep is used to wait for 05 mins after cluster resource creation,
# this is needed for the cluster to succesfully initialize 
resource "time_sleep" "wait" {
  depends_on      = [module.cluster]
  create_duration = var.create_duration
}

module "cluster_roles" {
  depends_on = [time_sleep.wait]
  source     = "app.terraform.io/pgetech/redshift/aws//modules/cluster_iam_roles"
  version    = "0.1.1"

  cluster_identifier = module.cluster.cluster_cluster_identifier
  iam_role_arns      = [module.firehose_aws_iam_role.arn]
}