moved {
  from = aws_api_gateway_rest_api.api
  to   = module.api_gateway.aws_api_gateway_rest_api.api_gateway_rest_api
}

moved {
  from = aws_api_gateway_stage.stage
  to   = module.api_deployment_and_stage.aws_api_gateway_stage.api_gateway_stage
}

moved {
  from = aws_api_gateway_method_settings.webhook_handler_post_settings
  to   = module.api_deployment_and_stage.aws_api_gateway_method_settings.api_gateway_method_settings[0]
}