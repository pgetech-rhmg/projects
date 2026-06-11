resource "aws_cloudtrail" "this" {
  name = local.effective_trail_name

  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  kms_key_id                    = var.kms_key_id
  sns_topic_name                = var.sns_topic_name

  cloud_watch_logs_group_arn = local.manage_cloudwatch_logs ? var.cloudwatch_logs_group_arn : null
  cloud_watch_logs_role_arn  = local.manage_cloudwatch_logs ? var.cloudwatch_logs_role_arn : null

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type           = event_selector.value.read_write_type
      include_management_events = event_selector.value.include_management_events

      dynamic "data_resource" {
        for_each = try(event_selector.value.data_resources, [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selectors
    content {
      name = try(advanced_event_selector.value.name, null)

      dynamic "field_selector" {
        for_each = try(advanced_event_selector.value.field_selectors, [])
        content {
          field           = field_selector.value.field
          equals          = try(field_selector.value.equals, null)
          not_equals      = try(field_selector.value.not_equals, null)
          starts_with     = try(field_selector.value.starts_with, null)
          not_starts_with = try(field_selector.value.not_starts_with, null)
          ends_with       = try(field_selector.value.ends_with, null)
          not_ends_with   = try(field_selector.value.not_ends_with, null)
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.is_multi_region_trail == true
      error_message = "is_multi_region_trail must be true per SAF Item #6 (multi-region coverage)."
    }

    precondition {
      condition     = var.enable_log_file_validation == true
      error_message = "enable_log_file_validation must be true per SAF Item #6 (log integrity validation)."
    }

    precondition {
      condition     = var.include_global_service_events == true
      error_message = "include_global_service_events must be true per SAF Item #6 (capture IAM/CloudFront/etc. global events)."
    }

    precondition {
      condition = !(
        local.is_high_classification &&
        (var.kms_key_id == null || length(trimspace(var.kms_key_id)) == 0)
      )
      error_message = "kms_key_id (CMK) is mandatory per SAF Item #2 when DataClassification is Confidential, Restricted, or Privileged."
    }
  }
}
