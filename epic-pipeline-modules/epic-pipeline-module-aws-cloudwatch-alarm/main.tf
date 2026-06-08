resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  namespace           = var.namespace
  metric_name         = var.metric_name
  statistic           = var.statistic
  comparison_operator = var.comparison_operator
  threshold           = var.threshold
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  dimensions          = var.dimensions
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  treat_missing_data  = var.treat_missing_data
  tags                = var.tags
}
