output "ecs_Appautoscalling_arn" {
  description = "ARN of Appautoscalling target"
  value       = aws_appautoscaling_target.target[*].arn
}

output "ecs_Appautoscalling_all" {
  description = "Map of ECS Appautoscalling"
  value       = aws_appautoscaling_target.target[*]
}