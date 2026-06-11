resource "aws_ses_configuration_set" "this" {
  name                       = local.effective_configuration_set_name
  reputation_metrics_enabled = var.reputation_metrics_enabled
  sending_enabled            = var.sending_enabled

  delivery_options {
    tls_policy = "Require"
  }

  dynamic "tracking_options" {
    for_each = length(var.custom_redirect_domain) > 0 ? [1] : []
    content {
      custom_redirect_domain = var.custom_redirect_domain
    }
  }
}

resource "aws_ses_event_destination" "this" {
  count = local.manage_event_destination ? 1 : 0

  name                   = var.event_destination.name
  configuration_set_name = aws_ses_configuration_set.this.name
  enabled                = var.event_destination.enabled
  matching_types         = var.event_destination.matching_types

  cloudwatch_destination {
    default_value  = var.event_destination.default_value
    dimension_name = var.event_destination.dimension_name
    value_source   = var.event_destination.value_source
  }
}
