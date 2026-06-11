# epic-pipeline-module-aws-lambda

Reusable Terraform module for provisioning an AWS Lambda function with its execution role, CloudWatch log group, and optional VPC attachment.

## Overview

This module is consumed by application `.infra/` directories whose `.pipeline/epic.json` declares an AWS deployment target. It provisions a single Lambda function from an S3-hosted deployment package and owns the surrounding IAM and logging resources so callers only supply per-function configuration (handler, environment, inline policy, layers, VPC).

The execution role is created with `AWSLambdaBasicExecutionRole` attached. When `vpc_config` is set, `AWSLambdaVPCAccessExecutionRole` is attached automatically. Additional managed policies and a single inline policy can be supplied for per-function grants.

## Resources

- `aws_lambda_function.this`
- `aws_iam_role.this` (execution role)
- `aws_iam_role_policy_attachment.basic_execution`
- `aws_iam_role_policy_attachment.vpc_access` (when `vpc_config` is set)
- `aws_iam_role_policy_attachment.additional` (one per `additional_policy_arns` entry)
- `aws_iam_role_policy.inline` (when `inline_policy` is set)
- `aws_cloudwatch_log_group.this` (`/aws/lambda/<function_name>`)

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `function_name` | `string` | Lambda function name. |
| `handler` | `string` | Lambda handler (e.g., `handler.handler`). |
| `s3_bucket` | `string` | S3 bucket containing the deployment package. |
| `s3_key` | `string` | S3 object key for the deployment package. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `description` | `string` | `""` | Lambda function description. |
| `runtime` | `string` | `"nodejs22.x"` | Lambda runtime (e.g., `nodejs24.x`). |
| `memory_size` | `number` | `256` | Memory allocation in MB. |
| `timeout` | `number` | `30` | Function timeout in seconds. |
| `environment_variables` | `map(string)` | `{}` | Environment variables for the function. |
| `layers` | `list(string)` | `[]` | List of Lambda layer ARNs. |
| `vpc_config` | `object({ subnet_ids = list(string), security_group_ids = list(string) })` | `null` | VPC configuration. When set, `AWSLambdaVPCAccessExecutionRole` is attached. |
| `reserved_concurrent_executions` | `number` | `-1` | Reserved concurrency. `-1` leaves the function unreserved. |
| `additional_policy_arns` | `list(string)` | `[]` | Additional IAM managed policy ARNs to attach to the execution role. |
| `inline_policy` | `string` | `null` | Inline IAM policy JSON for the execution role. |
| `log_retention_days` | `number` | `30` | CloudWatch log group retention in days. |
| `tracing_mode` | `string` | `"PassThrough"` | X-Ray tracing mode (`Active` or `PassThrough`). |
| `tags` | `map(string)` | `{}` | Resource tags. |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Lambda function name. |
| `function_arn` | Lambda function ARN. |
| `invoke_arn` | Lambda function invoke ARN (for API Gateway integration). |
| `role_arn` | IAM execution role ARN. |
| `role_name` | IAM execution role name. |
| `log_group_name` | CloudWatch log group name. |

## Usage in a Terraform Project

Direct call from an application's `.infra/` directory. This is the canonical pattern: one module call per logical function, fanning out via `for_each` over a local map.

```hcl
module "lambda" {
  for_each = local.functions

  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-lambda.git?ref=main"

  function_name = "${each.key}-${var.environment}"
  handler       = local.lambda_handler
  runtime       = local.lambda_runtime
  s3_bucket     = var.lambda_artifact_bucket
  s3_key        = "${var.lambda_artifact_key_prefix}/${each.key}.zip"

  timeout     = each.value.timeout
  memory_size = each.value.memory

  vpc_config = {
    subnet_ids         = local.private_subnet_ids
    security_group_ids = [module.lambda_security_group.aws_security_group_id]
  }

  environment_variables = {
    ENVIRONMENT             = var.environment
    APP_NAME                = var.project_tag
    DB_PROXY_ENDPOINT       = module.rds_proxy.proxy_endpoint
    DB_NAME                 = var.aurora_database_name
    DB_PROXY_USER           = each.key
    SES_SENDER_DOMAIN       = var.ses_sender_domain
    SES_CONFIGURATION_SET   = module.ses.configuration_set_name
    BOUNCE_SNS_TOPIC_ARN    = module.sns_ses_bounce.topic_arn
    OBSERVABILITY_TOPIC_ARN = module.sns_observability_alerts.topic_arn
    SETTINGS_PARAM_PREFIX   = "/${var.project_tag}/${var.environment}/"
  }

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RdsDbConnect"
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "arn:aws:rds-db:${var.aws_region}:${var.aws_account_id}:dbuser:${local.rds_proxy_resource_id}/${each.key}"
      },
      {
        Sid    = "ReadAppSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:nfr/${var.environment}/*"
      },
      {
        Sid    = "ReadAppSsmParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.project_tag}/${var.environment}/*"
      },
      {
        Sid    = "DecryptAppKeys"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = [
          module.kms_lambda.key_arn,
          module.kms_secrets.key_arn,
        ]
      },
      {
        Sid    = "PublishObservability"
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = [
          module.sns_observability_alerts.topic_arn,
          module.sns_ses_bounce.topic_arn,
        ]
      },
      {
        Sid    = "SendEmail"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ses:FromAddress" = "no-reply@${var.ses_sender_domain}"
          }
        }
      },
    ]
  })

  tags = module.tags.tags
}

# Lambda invoke permissions for API Gateway — one per API-fronted function.
resource "aws_lambda_permission" "api_gateway_invoke" {
  for_each = toset(local.api_fronted_function_names)

  statement_id  = "AllowAPIGatewayInvoke-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda[each.value].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.rest_api_arn}/*/*"
}
```

## Usage from Another Module

Composition pattern: a parent module wraps this module to produce a fleet of functions with a shared layer, security group, and policy contract. The parent exposes only the per-function map (`local.functions`) and forwards everything else.

```hcl
locals {
  functions = {
    api_get  = { handler = "api/get.handler",  timeout = 10, memory = 256 }
    api_post = { handler = "api/post.handler", timeout = 10, memory = 256 }
    worker   = { handler = "worker/index.handler", timeout = 60, memory = 512 }
  }
}

module "lambda" {
  for_each = local.functions

  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-lambda.git?ref=main"

  function_name = "${var.project_tag}-${each.key}-${var.environment}"
  handler       = each.value.handler
  runtime       = "nodejs22.x"
  timeout       = each.value.timeout
  memory_size   = each.value.memory

  s3_bucket = var.lambda_artifact_bucket
  s3_key    = "${var.lambda_artifact_key_prefix}/${each.key}.zip"

  layers = [aws_lambda_layer_version.shared.arn]

  vpc_config = {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [module.lambda_security_group.aws_security_group_id]
  }

  environment_variables = merge(
    local.common_env,
    try(each.value.extra_env, {}),
  )

  inline_policy = data.aws_iam_policy_document.app.json

  tags = module.tags.tags
}

output "function_arns" {
  value = { for k, m in module.lambda : k => m.function_arn }
}

output "invoke_arns" {
  value = { for k, m in module.lambda : k => m.invoke_arn }
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- The CloudWatch log group is created and managed by the module (`/aws/lambda/<function_name>`) — do not declare it in the caller. The Lambda is wired to it via `logging_config` with `log_format = "JSON"`.
- `reserved_concurrent_executions` uses `-1` as the sentinel for "unreserved." Any value `>= 0` is passed through to the Lambda resource as a concrete reservation.
- `layers` is omitted from the Lambda resource when empty (passed as `null`) to avoid spurious diffs.
- `environment` and `vpc_config` blocks are dynamic — they are only emitted when the corresponding inputs are non-empty / non-null.
- API Gateway `aws_lambda_permission` resources are out of scope for this module; declare them alongside the module call (see the project example above).
