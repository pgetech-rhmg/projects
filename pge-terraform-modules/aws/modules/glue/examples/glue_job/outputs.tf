# Outputs for Glue Job

output "glue_job_arn" {
  description = "Amazon Resource Name (ARN) of Glue Job"
  value       = module.glue_job.glue_job_arn
}

output "glue_job_id" {
  description = " Job name"
  value       = module.glue_job.glue_job_id
}

output "glue_job_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = module.glue_job.glue_job_tags_all
}

# Outputs for Glue Connection

output "glue_connection_id" {
  description = "Catalog ID and name of the connection"
  value       = module.glue_connection.glue_connection_id
}

output "glue_connection_arn" {
  description = "The ARN of the Glue Connection."
  value       = module.glue_connection.glue_connection_arn
}

output "glue_connections_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = module.glue_connection.glue_connection_tags_all
}

# Outputs for Glue Security Configuration

output "glue_security_configuration_id" {
  description = "Glue security configuration name"
  value       = module.glue_security_configuration.glue_security_configuration_id
}

# Outputs for Glue Trigger

output "glue_trigger_arn" {
  description = "Amazon Resource Name (ARN) of Glue Trigger"
  value       = module.glue_trigger.glue_trigger_arn
}

output "glue_trigger_id" {
  description = "Trigger name"
  value       = module.glue_trigger.glue_trigger_id
}

output "glue_trigger_state" {
  description = "The current state of the trigger."
  value       = module.glue_trigger.glue_trigger_state
}

output "glue_trigger_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = module.glue_trigger.glue_trigger_tags_all
}

# Outputs for Glue Dev Endpoint

output "glue_dev_endpoint_arn" {
  description = "The ARN of the endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_arn
}

output "glue_dev_endpoint_name" {
  description = "The name of the new endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_name
}

output "glue_dev_endpoint_private_address" {
  description = "A private IP address to access the endpoint within a VPC, if this endpoint is created within one."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_private_address
}

output "glue_dev_endpoint_public_address" {
  description = "The public IP address used by this endpoint. The PublicAddress field is present only when you create a non-VPC endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_public_address
}

output "glue_dev_endpoint_yarn_endpoint_address" {
  description = "The YARN endpoint address used by this endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_yarn_endpoint_address
}

output "glue_dev_endpoint_zeppelin_remote_spark_interpreter_port" {
  description = "The Apache Zeppelin port for the remote Apache Spark interpreter."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_zeppelin_remote_spark_interpreter_port
}

output "glue_dev_endpoint_availability_zone" {
  description = "The AWS availability zone where this endpoint is located."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_availability_zone
}

output "glue_dev_endpoint_vpc_id" {
  description = "The ID of the VPC used by this endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_vpc_id
}

output "glue_dev_endpoint_status" {
  description = "The current status of this endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_status
}

output "glue_dev_endpoint_failure_reason" {
  description = "The reason for a current failure in this endpoint."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_failure_reason
}

output "glue_dev_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider."
  value       = module.glue_dev_endpoint.glue_dev_endpoint_tags_all
}