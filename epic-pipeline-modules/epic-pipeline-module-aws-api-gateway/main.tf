resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.description

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.endpoint_type == "PRIVATE" ? var.vpc_endpoint_ids : null
  }

  tags = var.tags
}

resource "aws_api_gateway_rest_api_policy" "this" {
  count       = var.endpoint_type == "PRIVATE" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.this.execution_arn}/*"
      },
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.this.execution_arn}/*"
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = var.vpc_endpoint_ids
          }
        }
      }
    ]
  })
}

resource "aws_api_gateway_authorizer" "this" {
  count                            = var.enable_authorizer ? 1 : 0
  name                             = "${var.api_name}-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  type                             = "TOKEN"
  authorizer_uri                   = var.authorizer_function_invoke_arn
  identity_source                  = var.authorizer_identity_source
  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl
}

resource "aws_lambda_permission" "authorizer" {
  count         = var.enable_authorizer ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.authorizer_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}

resource "aws_api_gateway_gateway_response" "this" {
  for_each      = toset(var.gateway_responses)
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = each.value

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = var.cors_allow_origins
    "gatewayresponse.header.Access-Control-Allow-Headers" = var.cors_allow_headers
    "gatewayresponse.header.Access-Control-Allow-Methods" = var.cors_allow_methods
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this.body,
      var.gateway_responses,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
  tags          = var.tags
}
