# Outputs for Storage gateway cache

output "cache_id" {
  description = "Combined gateway Amazon Resource Name (ARN) and local disk identifier."
  value       = aws_storagegateway_cache.cache.id
}