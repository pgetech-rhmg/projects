/*
 * # AWS Elastic Beanstalk environment module.
 * Terraform module which creates SAF2.0 aws_elastic_beanstalk_environment in AWS.
*/
#
#  Filename    : aws/modules/elastic-beanstalk/modules/environment/main.tf
#  Date        : 19 October 2022
#  Author      : TCS
#  Description : Elastic Beanstalk environment Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })


  alb_settings = [{
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
    },
    {
      # As per SAF, the Application Load Balancers should not allow connection requests over HTTP and the HTTPS listener configured with a valid certificate.
      namespace = "aws:elbv2:listener:default"
      name      = "Protocol"
      value     = "HTTPS"
    },
    {
      namespace = "aws:elbv2:listener:default"
      name      = "SSLCertificateArns"
      value     = var.alb_settings.alb_certificate_arn
    },
    {
      #Application Load Balancer access logs should be stored in an S3 bucket with server-side encryption enabled
      namespace = "aws:elbv2:loadbalancer"
      name      = "AccessLogsS3Bucket"
      value     = var.alb_settings.elb_logs_s3_bucket_name
    },
    {
      #Application Load Balancer access logs should be stored in an S3 bucket with server-side encryption enabled
      namespace = "aws:elbv2:loadbalancer"
      name      = "AccessLogsS3Enabled"
      value     = "true"
    },
    {
      #As per SAF, all Application Load Balancers that are meant to be internal facing are deployed in a private subnet.
      namespace = "aws:ec2:vpc"
      name      = "ELBScheme"
      value     = "internal"
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(", ", var.alb_settings.elb_subnets)
  }]

  asg_settings = [{
    #As per SAF, EC2 auto-scaling groups must be deployed into a VPC.
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.asg_settings.vpcid
    },
    {
      #As per SAF, EC2 auto-scaling groups should only be deployed in private subnets and should not be accessible from the internet.
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(", ", var.asg_settings.asg_subnets)
  }]

  ebs_settings = [{
    #As per SAF, Ensure Elastic Beanstalk Persistent Logs are enabled
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }]

  db_settings = [{
    namespace = "aws:rds:dbinstance"
    name      = "HasCoupledDatabase"
    value     = var.db_settings.rds
    },
    {
      namespace = "aws:rds:dbinstance"
      name      = "DBEngine"
      value     = var.db_settings.engine
    },
    {
      namespace = "aws:rds:dbinstance"
      name      = "DBEngineVersion"
      value     = var.db_settings.version
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "DBSubnets"
      value     = var.db_settings.vpc_subnets == null ? null : join(", ", var.db_settings.vpc_subnets)
    },
    {
      namespace = "aws:rds:dbinstance"
      name      = "DBPassword"
      value     = local.db_password
  }]

  db_password_sm_list      = var.db_settings.secretsmanager_db_password_secret_name == null ? null : split(":", var.db_settings.secretsmanager_db_password_secret_name)
  db_password_sm_name      = var.db_settings.secretsmanager_db_password_secret_name == null ? null : local.db_password_sm_list[0]
  db_password_sm_key_name  = var.db_settings.secretsmanager_db_password_secret_name == null ? null : length(local.db_password_sm_list) == 2 ? local.db_password_sm_list[1] : null
  db_password_sm_key_value = var.db_settings.secretsmanager_db_password_secret_name == null ? null : local.db_password_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.db_password_id[0].secret_string)[local.db_password_sm_key_name] : null
  db_password              = var.db_settings.secretsmanager_db_password_secret_name == null ? null : local.db_password_sm_key_value != null ? local.db_password_sm_key_value : data.aws_secretsmanager_secret_version.db_password_id[0].secret_string

}


module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

data "aws_secretsmanager_secret" "db_password" {
  count = var.db_settings.secretsmanager_db_password_secret_name != null ? 1 : 0
  name  = local.db_password_sm_name
}

data "aws_secretsmanager_secret_version" "db_password_id" {
  count     = var.db_settings.secretsmanager_db_password_secret_name != null ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.db_password[0].id
}

resource "aws_elastic_beanstalk_environment" "environment" {

  name                   = var.name
  application            = var.application_name
  cname_prefix           = var.cname_prefix
  description            = coalesce(var.description, format("%s Elastic Beanstalk - Managed by Terraform", var.name))
  tier                   = var.tier
  solution_stack_name    = var.solution_stack_name
  template_name          = var.template_name
  platform_arn           = var.platform_arn
  wait_for_ready_timeout = var.wait_for_ready_timeout
  poll_interval          = var.poll_interval
  version_label          = var.version_label

  #If user needs to pass additional settings for elastic beanstalk, the user can pass the values through the settings variable.
  dynamic "setting" {
    for_each = var.settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  #This block handles all the settings assossiated with alb for elastic beanstalk as per SAF
  dynamic "setting" {
    for_each = local.alb_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  #This block handles all the settings assossiated with asg for elastic beanstalk as per SAF
  dynamic "setting" {
    for_each = local.asg_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  #This block handles all the settings assossiated with elastic beanstalk as per SAF
  dynamic "setting" {
    for_each = local.ebs_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  #settings for database. This block will only execute if var.db_settings.rds is given as 'true'.
  dynamic "setting" {
    for_each = var.db_settings.rds == true ? local.db_settings : []
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = lookup(setting.value, "resource", null)
    }
  }

  tags = local.module_tags
}