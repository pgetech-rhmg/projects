resource "aws_cloudwatch_log_group" "this" {
  count = local.manage_log_group ? 1 : 0

  name              = local.effective_log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.log_group_kms_key_id
  skip_destroy      = var.log_group_skip_destroy

  tags = var.tags

  lifecycle {
    precondition {
      condition = !(
        local.is_high_classification &&
        (var.log_group_kms_key_id == null || length(trimspace(var.log_group_kms_key_id)) == 0)
      )
      error_message = "log_group_kms_key_id (CMK) is mandatory per SAF Item #2 when DataClassification is Confidential, Restricted, or Privileged."
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.manage_metric_filters && local.manage_log_group ? {
    for f in var.metric_filters : f.name => f
  } : {}

  name           = each.value.name
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.this[0].name

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.default_value
    unit          = each.value.unit
  }
}

resource "aws_cloudwatch_dashboard" "this" {
  count = local.manage_dashboard ? 1 : 0

  dashboard_name = local.effective_dashboard
  dashboard_body = var.dashboard_body
}
