# Outputs for Glue Dev Endpoint
output "aws_glue_dev_endpoint" {
  description = "The map of aws_glue_dev_endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint
}

output "glue_dev_endpoint_arn" {
  description = "The ARN of the endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.arn
}

output "glue_dev_endpoint_name" {
  description = "The name of the new endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.name
}

output "glue_dev_endpoint_private_address" {
  description = "A private IP address to access the endpoint within a VPC, if this endpoint is created within one."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.private_address
}

output "glue_dev_endpoint_public_address" {
  description = "The public IP address used by this endpoint. The PublicAddress field is present only when you create a non-VPC endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.public_address
}

output "glue_dev_endpoint_yarn_endpoint_address" {
  description = "The YARN endpoint address used by this endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.yarn_endpoint_address
}

output "glue_dev_endpoint_zeppelin_remote_spark_interpreter_port" {
  description = "The Apache Zeppelin port for the remote Apache Spark interpreter."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.zeppelin_remote_spark_interpreter_port
}

output "glue_dev_endpoint_availability_zone" {
  description = "The AWS availability zone where this endpoint is located."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.availability_zone
}

output "glue_dev_endpoint_vpc_id" {
  description = "The ID of the VPC used by this endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.vpc_id
}

output "glue_dev_endpoint_status" {
  description = "The current status of this endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.status
}

output "glue_dev_endpoint_failure_reason" {
  description = "The reason for a current failure in this endpoint."
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.failure_reason
}

output "glue_dev_endpoint_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_glue_dev_endpoint.glue_dev_endpoint.tags_all
}