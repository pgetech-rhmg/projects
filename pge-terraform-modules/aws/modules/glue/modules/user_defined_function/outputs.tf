output "user_defined_function_id" {
  description = "The id of the Glue User Defined Function."
  value       = aws_glue_user_defined_function.user_defined_function.id
}

output "user_defined_function_arn" {
  description = "The ARN of the Glue User Defined Function."
  value       = aws_glue_user_defined_function.user_defined_function.arn
}

output "user_defined_function_create_time" {
  description = "The time at which the function was created."
  value       = aws_glue_user_defined_function.user_defined_function.create_time
}

output "aws_glue_user_defined_function" {
  description = "A map of aws_glue_user_defined_function object."
  value       = aws_glue_user_defined_function.user_defined_function
}