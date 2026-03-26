# Outputs
#################################################

output "lambda_function_rds_auto_start_arn" {
  value       = module.lambda_function_rds_auto_start.lambda_arn
  description = "value of the lambda start function arn"
}

output "lambda_function_rds_auto_stop_arn" {
  value       = module.lambda_function_rds_auto_stop.lambda_arn
  description = "value of the lambda stop function arn"
}

output "cloudwatch_event_rule_schedule_start_arn" {
  value       = aws_cloudwatch_event_rule.schedule-start.arn
  description = "value of the cloudwatch event rule schedule start arn"
}

output "cloudwatch_event_rule_schedule_stop_arn" {
  value       = aws_cloudwatch_event_rule.schedule-stop.arn
  description = "value of the cloudwatch event rule schedule stop arn"
}