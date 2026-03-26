output "lambda_arn" {
  value       = module.lambda_function.lambda_arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "sns_arn" {
  value       = aws_sns_topic.sns-topic-trigger-lambda.arn
  description = "Arn of the sns"
}