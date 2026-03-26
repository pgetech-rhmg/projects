# Module      : EMR serverless
# Description : This terraform module creates an EMR serverless

locals {
  namespace       = "ccoe-tf-developers"
  principal_orgid = "o-7vgpdbu22o"
  module_tags     = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

resource "aws_emrserverless_application" "this" {
    #required inputs
    name                = var.name
    release_label       = try(coalesce(var.release_label, element(data.aws_emr_release_labels.this.release_labels, 0)), "")
    type                = var.type

    #optional inputs
    region              = var.region
    
    architecture = var.architecture

    dynamic "auto_start_configuration" {
      for_each = var.auto_start_configuration != null ? [var.auto_start_configuration] : []
      content {
        enabled = lookup(auto_start_configuration.value, "enabled", null)
      }
    }

    dynamic "auto_stop_configuration" {
      for_each = var.auto_stop_configuration != null ? [var.auto_stop_configuration] : []
      content {
        enabled = lookup(auto_stop_configuration.value, "enabled", null)
        idle_timeout_minutes = lookup(auto_stop_configuration.value, "idle_timeout_minutes", null)
      }
    }

    dynamic "image_configuration" {
        for_each = var.image_configuration != null ? [var.image_configuration] : []
        content {
            image_uri = lookup(image_configuration.value, "image_uri", null)
        }
    }
    
    dynamic "initial_capacity" {
      for_each = var.initial_capacity != null ? var.initial_capacity : {}
      content {
        initial_capacity_type = initial_capacity.value.initial_capacity_type

        dynamic "initial_capacity_config" {
          for_each = lookup(initial_capacity.value, "initial_capacity_config", null) != null ? [initial_capacity.value.initial_capacity_config] : []
          content {
            worker_count = initial_capacity_config.value.worker_count

            dynamic "worker_configuration" {
              for_each = lookup(initial_capacity_config.value, "worker_configuration", null) != null ? [initial_capacity_config.value.worker_configuration] : []
              content {
                cpu    = worker_configuration.value.cpu
                memory = worker_configuration.value.memory
                disk   = lookup(worker_configuration.value, "disk", null)
              }
            }
          }
        }
      }
    }

    dynamic "interactive_configuration" {
      for_each = var.interactive_configuration != null ? [var.interactive_configuration] : []
      content {
        livy_endpoint_enabled = lookup(interactive_configuration.value, "livy_endpoint_enabled", null)
        studio_enabled        = lookup(interactive_configuration.value, "studio_enabled", null)
      }
    }

    dynamic "maximum_capacity" {
        for_each = var.maximum_capacity != null ? [var.maximum_capacity] : []
        content {
          cpu = maximum_capacity.value.cpu
          memory = maximum_capacity.value.memory
          disk = lookup(maximum_capacity.value, "disk", null)
        }
    }

  dynamic "monitoring_configuration" {
    for_each = var.monitoring_configuration != null ? [var.monitoring_configuration] : []

    content {
      dynamic "cloudwatch_logging_configuration" {
        for_each = monitoring_configuration.value.cloudwatch_logging_configuration != null ? [monitoring_configuration.value.cloudwatch_logging_configuration] : []

        content {
          enabled                = cloudwatch_logging_configuration.value.enabled
          log_group_name         = try(cloudwatch_logging_configuration.value.log_group_name, "/aws/emr-serverless/${var.name}")
          log_stream_name_prefix = try(cloudwatch_logging_configuration.value.log_stream_name_prefix, null)
          encryption_key_arn     = try(cloudwatch_logging_configuration.value.encryption_key_arn, null)

          dynamic "log_types" {
            for_each = cloudwatch_logging_configuration.value.log_types != null ? cloudwatch_logging_configuration.value.log_types : []

            content {
              name   = log_types.value.name
              values = log_types.value.values
            }
          }
        }
      }

      dynamic "managed_persistence_monitoring_configuration" {
        for_each = monitoring_configuration.value.managed_persistence_monitoring_configuration != null ? [monitoring_configuration.value.managed_persistence_monitoring_configuration] : []

        content {
          enabled            = managed_persistence_monitoring_configuration.value.enabled
          encryption_key_arn = managed_persistence_monitoring_configuration.value.encryption_key_arn
        }
      }

      dynamic "prometheus_monitoring_configuration" {
        for_each = monitoring_configuration.value.prometheus_monitoring_configuration != null ? [monitoring_configuration.value.prometheus_monitoring_configuration] : []

        content {
          remote_write_url = prometheus_monitoring_configuration.value.remote_write_url
        }
      }

      dynamic "s3_monitoring_configuration" {
        for_each = monitoring_configuration.value.s3_monitoring_configuration != null ? [monitoring_configuration.value.s3_monitoring_configuration] : []

        content {
          log_uri            = s3_monitoring_configuration.value.log_uri
          encryption_key_arn = s3_monitoring_configuration.value.encryption_key_arn
        }
      }
    }
  }
  
    dynamic "network_configuration" {
      for_each = var.network_configuration != null ? [var.network_configuration] : []
      content {
        subnet_ids = lookup(network_configuration.value, "subnet_ids", null)
        security_group_ids = lookup(network_configuration.value, "security_group_ids", null)
      }
    }

    dynamic "scheduler_configuration" {
      for_each = var.scheduler_configuration != null ? [var.scheduler_configuration] : []
      content {
        max_concurrent_runs   = lookup(scheduler_configuration.value, "max_concurrent_runs", null)
        queue_timeout_minutes = lookup(scheduler_configuration.value, "queue_timeout_minutes", null)
      }
    }

    tags = local.module_tags

}
