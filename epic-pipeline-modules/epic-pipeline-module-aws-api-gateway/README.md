# epic-pipeline-module-aws-api-gateway

## Overview

Provisions an AWS API Gateway REST API with a deployment, stage, CORS-aware gateway responses, and an optional Lambda TOKEN authorizer. Supports `REGIONAL`, `EDGE`, and `PRIVATE` endpoint types; when `PRIVATE`, attaches a resource policy that restricts invocation to the supplied VPC endpoints.

This module is consumed from an application's `.infra/` directory and is orchestrated by the EPIC pipeline when an app's `.pipeline/epic.json` declares an AWS deployment with infrastructure.

---

## Resources

- `aws_api_gateway_rest_api` — REST API with endpoint configuration
- `aws_api_gateway_rest_api_policy` — VPCE-restricted resource policy (PRIVATE only)
- `aws_api_gateway_authorizer` — Lambda TOKEN authorizer (when `enable_authorizer = true`)
- `aws_lambda_permission` — allows API Gateway to invoke the authorizer Lambda
- `aws_api_gateway_gateway_response` — CORS headers on configured gateway response types
- `aws_api_gateway_deployment` — redeploys when API body or gateway responses change
- `aws_api_gateway_stage` — deployment stage

---

## Inputs

### Required

| Name | Type | Description |
|---|---|---|
| `api_name` | `string` | REST API name. |
| `stage_name` | `string` | Deployment stage name. |

### Optional

| Name | Type | Default | Description |
|---|---|---|---|
| `description` | `string` | `""` | REST API description. |
| `endpoint_type` | `string` | `"PRIVATE"` | Endpoint type: `REGIONAL`, `EDGE`, or `PRIVATE`. |
| `vpc_endpoint_ids` | `list(string)` | `[]` | VPC endpoint IDs for `PRIVATE` endpoint type. |
| `enable_authorizer` | `bool` | `false` | Whether to create the Lambda authorizer resources. |
| `authorizer_function_arn` | `string` | `null` | Lambda authorizer function ARN. |
| `authorizer_function_invoke_arn` | `string` | `null` | Lambda authorizer invoke ARN. |
| `authorizer_identity_source` | `string` | `"method.request.header.Authorization"` | Authorizer identity source header. |
| `authorizer_result_ttl` | `number` | `300` | Authorizer result cache TTL in seconds. |
| `cors_allow_origins` | `string` | `"'*'"` | CORS allowed origins (note the embedded single quotes). |
| `cors_allow_methods` | `string` | `"'GET,POST,PUT,PATCH,DELETE,OPTIONS'"` | CORS allowed methods. |
| `cors_allow_headers` | `string` | `"'Content-Type,Authorization'"` | CORS allowed headers. |
| `gateway_responses` | `list(string)` | `["UNAUTHORIZED","ACCESS_DENIED","DEFAULT_5XX","DEFAULT_4XX"]` | Gateway response types to decorate with CORS headers. |
| `tags` | `map(string)` | `{}` | Resource tags. |

---

## Outputs

| Name | Description |
|---|---|
| `rest_api_id` | REST API ID. |
| `rest_api_arn` | REST API ARN. |
| `execution_arn` | REST API execution ARN, used for `aws_lambda_permission.source_arn`. |
| `root_resource_id` | REST API root resource ID, used to attach resources/methods. |
| `stage_invoke_url` | Stage invoke URL. |
| `authorizer_id` | Authorizer ID, or `null` when `enable_authorizer = false`. |

---

## Usage in a Terraform project

Private REST API behind a shared transit VPC endpoint with CORS-decorated gateway responses:

```hcl
module "api_gateway" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-api-gateway.git?ref=main"

  api_name   = "${var.project_tag}-api-${var.environment}"
  stage_name = var.environment

  endpoint_type    = "PRIVATE"
  vpc_endpoint_ids = [var.vpc_endpoint_id]

  cors_allow_origins = "'*'"
  cors_allow_methods = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
  cors_allow_headers = "'Content-Type,Authorization,x-api-key'"

  gateway_responses = ["UNAUTHORIZED", "ACCESS_DENIED", "DEFAULT_4XX", "DEFAULT_5XX"]

  tags = module.tags.tags
}
```

Attaching a custom domain and Route 53 alias on top of the module:

```hcl
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.api_custom_domain_name
  regional_certificate_arn = module.api_certificate.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = module.tags.tags
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = module.api_gateway.rest_api_id
  stage_name  = var.environment
  domain_name = aws_api_gateway_domain_name.api.domain_name
}
```

---

## Usage from another module (composition)

When a Lambda authorizer is co-deployed, pass its ARNs in and wire `aws_lambda_permission` for downstream functions to the API's `execution_arn`:

```hcl
module "api_gateway" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-api-gateway.git?ref=main"

  api_name         = "${var.project_tag}-Api-${var.environment}"
  description      = "${var.project_tag} REST API"
  endpoint_type    = "PRIVATE"
  vpc_endpoint_ids = [var.vpc_endpoint_id]
  stage_name       = var.environment

  enable_authorizer              = true
  authorizer_function_arn        = module.lambda["authorizer"].function_arn
  authorizer_function_invoke_arn = module.lambda["authorizer"].invoke_arn
  authorizer_result_ttl          = 300

  cors_allow_headers = "'Content-Type,Authorization,X-Graph-Token'"

  tags = module.tags.tags
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = local.api_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*"
}
```

The module itself only registers the authorizer's invoke permission. Method/route resources, integrations, and per-function `aws_lambda_permission` blocks are the caller's responsibility.

---

## Versions

| Requirement | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

---

## Notes

- CORS string inputs must include the embedded single quotes (e.g. `"'*'"`) — API Gateway response parameters require quoted literals.
- The deployment is redeployed when `aws_api_gateway_rest_api.body` or `gateway_responses` change. Adding or modifying methods/integrations outside the module will not on its own trigger a redeploy; consumers that mutate the API surface should manage their own deployment trigger or taint as needed.
- For `PRIVATE` endpoints, supply at least one VPC endpoint ID in `vpc_endpoint_ids` — the resource policy denies any invocation whose `aws:sourceVpce` is not in that list.
