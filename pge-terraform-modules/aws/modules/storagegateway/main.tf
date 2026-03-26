/*
* # AWS storagegateway file_gateway module
* # Terraform module which creates aws_storagegateway_gateway
*/
# Filename     : aws/modules/storagegateway/main.tf 
# Date         : 22 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_storagegateway_gateway

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

resource "aws_storagegateway_gateway" "gateway" {
  gateway_name              = var.gateway_name
  gateway_timezone          = var.gateway_timezone
  activation_key            = var.activation_gateway.activation_key
  gateway_ip_address        = var.activation_gateway.gateway_ip_address
  gateway_type              = var.gateway_type
  gateway_vpc_endpoint      = var.gateway_vpc_endpoint
  cloudwatch_log_group_arn  = var.cloudwatch_log_group_arn
  smb_security_strategy     = var.smb_security_strategy
  smb_file_share_visibility = var.smb_file_share_visibility

  # maintenance_start_time is optional so this block will execute only when user provides the reqired input until it will be disabled  
  dynamic "maintenance_start_time" {
    for_each = var.maintenance_start_time.hour_of_day != null && var.maintenance_start_time.minute_of_hour != null ? [true] : []
    content {
      day_of_month   = var.maintenance_start_time.day_of_month
      day_of_week    = var.maintenance_start_time.day_of_week
      hour_of_day    = var.maintenance_start_time.hour_of_day
      minute_of_hour = var.maintenance_start_time.minute_of_hour
    }
  }

  dynamic "smb_active_directory_settings" {
    for_each = var.smb_active_directory_settings.domain_name != null && var.smb_active_directory_settings.password != null && var.smb_active_directory_settings.username != null ? [true] : []
    content {
      domain_name         = var.smb_active_directory_settings.domain_name
      password            = var.smb_active_directory_settings.password
      username            = var.smb_active_directory_settings.username
      timeout_in_seconds  = var.smb_active_directory_settings.timeout_in_seconds
      organizational_unit = var.smb_active_directory_settings.organizational_unit
      domain_controllers  = var.smb_active_directory_settings.domain_controllers
    }
  }
  tags = merge(var.tags, { pge_team = local.namespace })

  timeouts {
    create = var.timeout_create
  }
}