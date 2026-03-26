locals {

  db_instance_address            = try(aws_db_instance.this[0].address, aws_db_instance.this_mssql[0].address, "")
  db_instance_arn                = try(aws_db_instance.this[0].arn, aws_db_instance.this_mssql[0].arn, "")
  db_instance_availability_zone  = try(aws_db_instance.this[0].availability_zone, aws_db_instance.this_mssql[0].availability_zone, "")
  db_instance_endpoint           = try(aws_db_instance.this[0].endpoint, aws_db_instance.this_mssql[0].endpoint, "")
  db_instance_hosted_zone_id     = try(aws_db_instance.this[0].hosted_zone_id, aws_db_instance.this_mssql[0].hosted_zone_id, "")
  db_instance_id                 = try(aws_db_instance.this[0].id, aws_db_instance.this_mssql[0].id, "")
  db_instance_identifier         = try(aws_db_instance.this[0].identifier, aws_db_instance.this_mssql[0].identifier, "")
  db_instance_resource_id        = try(aws_db_instance.this[0].resource_id, aws_db_instance.this_mssql[0].resource_id, "")
  db_instance_status             = try(aws_db_instance.this[0].status, aws_db_instance.this_mssql[0].status, "")
  db_instance_name               = try(aws_db_instance.this[0].db_name, aws_db_instance.this_mssql[0].db_name, "")
  db_instance_username           = try(aws_db_instance.this[0].username, aws_db_instance.this_mssql[0].username, "")
  db_instance_port               = try(aws_db_instance.this[0].port, aws_db_instance.this_mssql[0].port, "")
  db_instance_ca_cert_identifier = try(aws_db_instance.this[0].ca_cert_identifier, aws_db_instance.this_mssql[0].ca_cert_identifier, "")
  db_instance_master_password    = try(aws_db_instance.this[0].password, aws_db_instance.this_mssql[0].password, "")
  db_instance_host               = element(split(":", local.db_instance_endpoint), 0)
  db_instance_master_user_secret = try(aws_db_instance.this[0].master_user_secret[0].secret_arn, aws_db_instance.this_mssql[0].master_user_secret[0].secret_arn, "")
}
output "db_instance_master_user_secret" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = local.db_instance_master_user_secret
}

output "db_instance_identifier" {
  description = "The identifier of the DB instance"
  value       = local.db_instance_identifier

}
output "aws_db_instance_this_all" {
  description = "Map of aws db instance"
  value       = aws_db_instance.this
}

output "aws_db_instance_this_mssql_all" {
  description = "Map of aws db instance for mssql"
  value       = aws_db_instance.this_mssql
}


output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = local.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = local.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = local.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = local.db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = local.db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = local.db_instance_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = local.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = local.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = local.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = local.db_instance_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = local.db_instance_port
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = local.db_instance_ca_cert_identifier
}


output "db_instance_master_password" {
  description = "The master password"
  value       = local.db_instance_master_password
  sensitive   = true
}
output "db_instance_host" {
  description = "The RDS address"
  value       = local.db_instance_host
}
