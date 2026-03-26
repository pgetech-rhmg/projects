# Expose workspace information for consumers of this module
output "workspace_info" {
  description = "Metadata about the Terraform Cloud workspace used by this module."
  value = {
    name = module.ws.name
    id   = module.ws.id
  }
}

# Expose the computed module tags so callers can reuse them with taggable resources
output "module_tags" {
  description = "Standardized tag map including workspace and team metadata."
  value       = local.module_tags
}