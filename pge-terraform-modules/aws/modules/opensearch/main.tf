/*
 * # AWS Opensearch domain module.
 * Terraform module which creates Opensearch domain in AWS.
*/
#  Filename    : aws/modules/opensearch/modules/domain/main.tf
#  Date        : 11 Apr 2024
#  Author      : PGE
#  Description : Opensearch Domain

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Description : Default for Tags

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}


# Module      : domain Creation
# Description : This terraform module creates a Opensearch domain.


resource "aws_opensearch_domain" "domain" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  dynamic "cluster_config" {
    for_each = var.cluster_config

    content {
      dedicated_master_enabled = try(cluster_config.value.dedicated_master_enabled, false)
      dedicated_master_type    = try(cluster_config.value.dedicated_master_type, "r5.large.search")
      dedicated_master_count   = try(cluster_config.value.dedicated_master_count, 1)
      instance_type            = try(cluster_config.value.instance_type, "r5.large.search")
      instance_count           = try(cluster_config.value.instance_count, 2)

      multi_az_with_standby_enabled = try(cluster_config.value.multi_az_with_standby_enabled, false)
      warm_enabled                  = try(cluster_config.value.warm_enabled, false)
      warm_count                    = try(cluster_config.value.warm_count, 2)
      warm_type                     = try(cluster_config.value.warm_type, "ultrawarm1.large.search")
      zone_awareness_enabled        = try(cluster_config.value.zone_awareness_enabled, false)
      dynamic "zone_awareness_config" {
        for_each = cluster_config.value.zone_awareness_enabled ? [1] : []

        content {
          availability_zone_count = lookup(cluster_config.value.zone_awareness_config, "availability_zone_count", 2)
        }

      }

      dynamic "cold_storage_options" {
        for_each = cluster_config.value.zone_awareness_enabled ? [1] : []

        content {
          enabled = lookup(cluster_config.value.cold_storage_options, "enabled", false)
        }
      }
    }
  }

  dynamic "vpc_options" {
    for_each = var.vpc_options

    content {
      subnet_ids         = vpc_options.value.subnet_ids
      security_group_ids = vpc_options.value.security_group_ids
    }
  }

  advanced_options = var.advanced_options

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options

    content {
      enabled                        = try(advanced_security_options.value.enabled, false)
      anonymous_auth_enabled         = try(advanced_security_options.value.anonymous_auth_enabled, false)
      internal_user_database_enabled = try(advanced_security_options.value.internal_user_database_enabled, true)
      master_user_options {
        master_user_name     = try(advanced_security_options.value.master_user_name, "example")
        master_user_password = try(advanced_security_options.value.master_user_password, "Barbarbarbar1!")
      }
    }
  }

  dynamic "encrypt_at_rest" {
    for_each = var.encrypt_at_rest_options

    content {
      enabled    = try(encrypt_at_rest.value.enabled, true)
      kms_key_id = try(encrypt_at_rest.value.kms_key_id, null)
    }
  }

  dynamic "domain_endpoint_options" {
    for_each = var.domain_endpoint_options

    content {
      enforce_https                   = try(domain_endpoint_options.value.enforce_https, true)
      tls_security_policy             = try(domain_endpoint_options.value.tls_security_policy, "Policy-Min-TLS-1-2-2019-07")
      custom_endpoint                 = try(domain_endpoint_options.value.custom_endpoint, null)
      custom_endpoint_certificate_arn = try(domain_endpoint_options.value.custom_endpoint_certificate_arn, null)
      custom_endpoint_enabled         = try(domain_endpoint_options.value.custom_endpoint_enabled, false)
    }
  }

  dynamic "node_to_node_encryption" {
    for_each = var.node_to_node_encryption_options

    content {
      enabled = try(node_to_node_encryption.value.enabled, false)
    }
  }

  dynamic "ebs_options" {
    for_each = var.ebs_options

    content {
      ebs_enabled = try(ebs_options.value.ebs_enabled, true)
      volume_size = try(ebs_options.value.volume_size, 300)
      iops        = try(ebs_options.value.iops, null)
      throughput  = try(ebs_options.value.throughput, null)
      volume_type = try(ebs_options.value.volume_type, null)
    }
  }

  # access_policies = data.aws_iam_policy_document.example.json

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options

    content {
      cloudwatch_log_group_arn = try(log_publishing_options.value.cloudwatch_log_group, null)
      log_type                 = try(log_publishing_options.value.log_type, "INDEX_SLOW_LOGS")
    }
  }

  tags = var.tags

}