output "dev_center_id" {
  description = "Resource ID of the Dev Center"
  value       = azapi_resource.dev_center.id
}

output "dev_center_name" {
  description = "Name of the Dev Center"
  value       = azapi_resource.dev_center.name
}

output "dev_center_project_id" {
  description = "Resource ID of the Dev Center Project (required for managed pools)"
  value       = azapi_resource.dev_center_project.id
}

output "dev_center_project_name" {
  description = "Name of the Dev Center Project"
  value       = azapi_resource.dev_center_project.name
}