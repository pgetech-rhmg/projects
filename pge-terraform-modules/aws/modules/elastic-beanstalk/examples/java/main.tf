/*
 * # AWS  Elastic Beanstalk User module example
*/
#
#  Filename    : aws/modules/elastic-beanstalk/examples//main.tf
#  Date        : 14 Oct 2022
#  Author      : TCS
#  Description : The terraform module creates a Elastic Beanstalk  application for java

locals {
  common_name = "${var.name}-${random_string.name.result}"
  Order       = var.Order
}
# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.0"
#   name        = "alias/kms${local.name}"
#   description = var.description
#   tags        = merge(module.tags.tags, var.optional_tags)
#   aws_role    = var.aws_role
#   policy      = local.kms_custom_policy
#   kms_role    = var.kms_role
# }

# VPC ID from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

# Subnet01 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

# Subnet02 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

# Subnet03 from SSM Parameter Store
data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

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
  Order              = local.Order
}

#######################################################################
#Elastic Beanstalk  application for java
#######################################################################

module "elastic_beanstalk_application" {
  source = "../../"

  name = local.common_name

  appversion_lifecycle = {
    service_role          = module.elastic_beanstalk_iam_role.arn
    max_count             = var.max_count
    delete_source_from_s3 = var.delete_source_from_s3
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

module "elastic_beanstalk_iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name   = local.common_name
  path   = var.path
  policy = [file("${path.module}/iam_policy_eb.json")]
  tags   = merge(module.tags.tags, var.optional_tags)
}

module "elastic_beanstalk_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.common_name
  aws_service = var.aws_service
  #Customer Managed Policy
  policy_arns = flatten([module.elastic_beanstalk_iam_policy.arn, var.policy_arns])
  tags        = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.elastic_beanstalk_iam_policy
  ]

}

resource "aws_iam_instance_profile" "elastic_beanstalk_instance_profile" {
  name = local.common_name
  role = module.elastic_beanstalk_iam_role.name
  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.elastic_beanstalk_iam_role
  ]
}

# Elastic Beanstalk Application version
module "elastic_beanstalk_application_version" {
  source = "../../modules/elastic_beanstalk_application_version"

  name         = var.application_version
  application  = module.elastic_beanstalk_application.name
  bucket       = module.s3.id
  key          = aws_s3_object.s3_object.key
  force_delete = var.application_version_force_delete
  tags         = merge(module.tags.tags, var.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = "application-${local.common_name}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, var.optional_tags)
}

resource "aws_s3_object" "s3_object" {
  bucket = module.s3.id
  key    = "tomcat-${var.application_version}.zip"
  source = "${path.module}/${var.application_version_source_zip}"
  tags   = merge(module.tags.tags, var.optional_tags)
}

module "kms" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.common_name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, var.optional_tags)
}

#######################################################################
#Elastic Beanstalk environment
#######################################################################

module "elastic_beanstalk_environment" {
  source = "../../modules/environment"

  name                = local.common_name
  application_name    = module.elastic_beanstalk_application.name
  solution_stack_name = var.environment_solution_stack_name
  version_label       = var.application_version

  asg_settings = {
    vpcid       = data.aws_ssm_parameter.vpc_id.value
    asg_subnets = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  }
  alb_settings = {
    elb_subnets             = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
    elb_logs_s3_bucket_name = module.s3_for_logs.id
    alb_certificate_arn     = module.acm.acm_certificate_arn
  }

  db_settings = {
    engine                                 = var.db_engine
    version                                = var.db_version
    rds                                    = var.rds
    vpc_subnets                            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
    secretsmanager_db_password_secret_name = var.secretsmanager_db_password_secret_name
  }

  settings = [{
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elastic_beanstalk_instance_profile.arn
  }]

  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [module.elastic_beanstalk_application_version]
}

module "s3_for_logs" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name   = "logs-${local.common_name}"
  force_destroy = true
  policy        = templatefile("${path.module}/${var.template_file_name}", { bucket_name = "logs-${local.common_name}", account_num = var.account_num, aws_role = var.aws_role })
  tags          = merge(module.tags.tags, var.optional_tags)
}

module "acm" {
  source  = "app.terraform.io/pgetech/acm/aws//modules/acm_import_certificate"
  version = "0.1.2"

  acm_private_key      = tls_private_key.private_key.private_key_pem
  acm_certificate_body = tls_self_signed_cert.self_signed_cert.cert_pem
  tags                 = merge(module.tags.tags, var.optional_tags)
}

resource "tls_private_key" "private_key" {
  algorithm = var.private_key_algorithm
}

resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem = tls_private_key.private_key.private_key_pem
  subject {
    common_name  = var.acm_domain_name
    organization = var.organization
  }

  validity_period_hours = var.validity_period_hours

  allowed_uses = var.allowed_uses
}