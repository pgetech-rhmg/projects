output "lambda_arn" {
  description = "The ARN of the Neptune Scale Lambda function"
  value       = module.neptune_scale_lambda.lambda_arn
}

output "lambda_name" {
  description = "The name of the Neptune Scale Lambda function"
  value       = local.lambda_name
}

output "parameter_name" {
  description = "The SSM Parameter name to trigger the Lambda"
  value       = aws_ssm_parameter.neptune_scale_trigger.name
}

output "eventbridge_rule_arn" {
  description = "The ARN of the EventBridge rule monitoring Parameter Store changes"
  value       = aws_cloudwatch_event_rule.parameter_change.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}
