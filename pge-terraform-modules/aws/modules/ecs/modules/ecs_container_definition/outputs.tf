output "json_map_encoded_list" {
  description = "JSON string encoded list of container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = "[${local.json_map}]"
}

output "json_map_encoded" {
  description = "JSON string encoded container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = local.json_map
}

output "json_map_object" {
  description = "JSON map encoded container definition"
  value       = jsondecode(local.json_map)
}

output "sensitive_json_map_encoded_list" {
  description = "JSON string encoded list of container definitions for use with other terraform resources such as aws_ecs_task_definition (sensitive)"
  value       = "[${local.json_map}]"
  sensitive   = true
}

output "sensitive_json_map_encoded" {
  description = "JSON string encoded container definitions for use with other terraform resources such as aws_ecs_task_definition (sensitive)"
  value       = local.json_map
  sensitive   = true
}

output "sensitive_json_map_object" {
  description = "JSON map encoded container definition (sensitive)"
  value       = jsondecode(local.json_map)
  sensitive   = true
}

output "container_name" {
  description = "Name of the container defined in the container_definition file"
  value       = local.container_definition.name
}


output "wiz_json_map_encoded_list" {
  description = "JSON string encoded list of wiz container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = "[${local.wiz_json_map}]"
}

output "wiz_json_map_encoded" {
  description = "JSON string encoded wiz container definitions for use with other terraform resources such as aws_ecs_task_definition"
  value       = local.wiz_json_map
}

output "wiz_json_map_object" {
  description = "JSON map encoded wiz container definition"
  value       = jsondecode(local.wiz_json_map)
}

output "wiz_container_name" {
  description = "Name of the wiz container defined in the wiz_container_definition file"
  value       = local.wiz_container_definition.name
}