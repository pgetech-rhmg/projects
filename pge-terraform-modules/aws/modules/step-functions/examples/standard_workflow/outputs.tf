output "state_machine_arn" {
  description = "The ARN of the state machine."
  value       = module.standard_workflow.state_machine_arn
}

output "state_machine_status" {
  description = "The current status of the state machine. Either ACTIVE or DELETING."
  value       = module.standard_workflow.state_machine_status
}

output "state_machine_version_arn" {
  description = "The ARN of the state machine version."
  value       = module.standard_workflow.state_machine_version_arn

}