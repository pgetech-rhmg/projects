output "endpoint_address" {
  description = "The DNS address of the endpoint."
  value       = aws_redshift_endpoint_access.endpoint.address
}

output "endpoint_id" {
  description = "The Redshift-managed VPC endpoint name."
  value       = aws_redshift_endpoint_access.endpoint.id
}

output "endpoint_port" {
  description = "The port number on which the cluster accepts incoming connections."
  value       = aws_redshift_endpoint_access.endpoint.port
}

output "vpc_endpoint" {
  description = "The connection endpoint for connecting to an Amazon Redshift cluster through the proxy."
  value       = aws_redshift_endpoint_access.endpoint.vpc_endpoint
}

output "aws_redshift_endpoint_access_all" {
  description = "A map of aws redshift endpoint access attributes references"
  value       = aws_redshift_endpoint_access.endpoint

}