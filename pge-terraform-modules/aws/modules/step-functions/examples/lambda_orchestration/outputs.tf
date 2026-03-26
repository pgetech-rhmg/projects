output "state_machine_arn" {
  description = "The ARN of the state machine."
  value       = module.lambda_orchestration.state_machine_arn
}

output "state_machine_status" {
  description = "The current status of the state machine. Either ACTIVE or DELETING."
  value       = module.lambda_orchestration.state_machine_status
}