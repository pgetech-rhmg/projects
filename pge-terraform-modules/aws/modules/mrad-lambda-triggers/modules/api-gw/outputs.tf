output "rest_api" {
  value = module.api_gateway.aws_api_gateway_rest_api_all
}

output "root_resource_id" {
  value = module.api_gateway.api_gateway_rest_api_root_resource_id
}

output "stage_name" {
  value = module.api_deployment_and_stage.api_gateway_stage_name
}

output "deployment" {
  value = module.api_deployment_and_stage.aws_api_gateway_deployment_all
}