################################################################################
# Fleet Outputs
################################################################################

output "appstream_fleet_arn" {
  description = "ARN of the appstream fleet."
  value       = module.fleet.arn
}

output "appstream_fleet_id" {
  description = "Unique identifier (ID) of the appstream fleet."
  value       = module.fleet.id
}

output "appstream_fleet_state" {
  description = "State of the fleet."
  value       = module.fleet.state
}

################################################################################
# Stack Outputs
################################################################################

output "appstream_stack_arn" {
  description = "ARN of the appstream stack."
  value       = module.stack_appstream.appstream_stack_arn
}

output "appstream_stack_created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the stack was created."
  value       = module.stack_appstream.appstream_stack_created_time
}

output "appstream_stack_id" {
  description = "Unique ID of the appstream stack."
  value       = module.stack_appstream.appstream_stack_id
}

################################################################################
# VPC Endpoint Outputs
################################################################################

# VPC Endpoint Outputs
################################################################################

output "vpc_endpoint_appstream_id" {
  description = "ID of the AppStream VPC endpoint."
  # Use this for resource (new VPC endpoint)
  value = aws_vpc_endpoint.appstream_streaming.id
  # Use this for data source (existing VPC endpoint)
  # value       = data.aws_vpc_endpoint.appstream_streaming.id
}

output "vpc_endpoint_appstream_dns_entry" {
  description = "DNS entries for the AppStream VPC endpoint."
  # Use this for resource (new VPC endpoint)
  value = aws_vpc_endpoint.appstream_streaming.dns_entry
  # Use this for data source (existing VPC endpoint)
  # value       = data.aws_vpc_endpoint.appstream_streaming.dns_entry
}