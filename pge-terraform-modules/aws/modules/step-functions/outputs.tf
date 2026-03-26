output "state_machine_id" {
  description = "The ARN of the state machine."
  value       = aws_sfn_state_machine.state_machine.id
}

output "state_machine_arn" {
  description = "The ARN of the state machine."
  value       = aws_sfn_state_machine.state_machine.arn
}

output "state_machine_version_arn" {
  description = "The ARN of the state machine version."
  value       = aws_sfn_state_machine.state_machine.state_machine_version_arn

}
output "state_machine_creation_date" {
  description = "The date the state machine was created."
  value       = aws_sfn_state_machine.state_machine.creation_date
}

output "state_machine_status" {
  description = "The current status of the state machine. Either ACTIVE or DELETING."
  value       = aws_sfn_state_machine.state_machine.status
}

output "state_machine_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = aws_sfn_state_machine.state_machine.tags_all
}

output "sfn_state_machine_all" {
  description = "A map of aws sfn state machine"
  value       = aws_sfn_state_machine.state_machine

}