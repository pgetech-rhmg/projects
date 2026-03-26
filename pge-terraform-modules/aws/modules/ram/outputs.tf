output "resource_share" {
  description = "Map of Resource share object"
  value       = aws_ram_resource_share.default
}

output "name" {
  value       = aws_ram_resource_share.default.name
  description = "The name of the RAM share created"
}

output "arn" {
  value       = aws_ram_resource_share.default.arn
  description = "The Amazon Resource Name (ARN) specifying the RAM share"
}