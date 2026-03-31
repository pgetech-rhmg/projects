################################################################################
# Step Function - AMI Build Orchestrator with Parallel Execution
################################################################################

resource "random_string" "name_randamizer" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# IAM Role for Step Function
module "step_function_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "amipipeline-step-function-role-${random_string.name_randamizer.result}"
  description = "IAM role for Step Function to orchestrate AMI builds"
  aws_service = ["states.amazonaws.com"]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "ImagebuilderAccess"
          Effect = "Allow"
          Action = [
            "imagebuilder:StartImagePipelineExecution",
            "imagebuilder:GetImage",
            "imagebuilder:GetImagePipeline",
            "imagebuilder:ListImageBuildVersions",
            "imagebuilder:ListImagePipelineImages"
          ]
          Resource = "*"
        },
        # EC2 permissions for 'describe AMIs'
        {
          Sid    = "EC2DescribeAccess"
          Effect = "Allow"
          Action = [
            "ec2:DescribeImages"
          ]
          Resource = "*"
        },
        # Lambda invocation permissions
        {
          Sid    = "LambdaInvoke"
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = [
            module.ami_writer_lambda.lambda_arn,
            module.tfc_runner_lambda.lambda_arn,
            module.config_manager_lambda.lambda_arn
          ]
        },
        # SSM parameter permissions
        {
          Sid    = "SSMParameterAccess"
          Effect = "Allow"
          Action = [
            "ssm:DeleteParameter",
            "ssm:GetParameter",
            "ssm:PutParameter",
          ]
          Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/ami_factory/*"
        },
        # CloudWatch log permissions
        {
          Sid    = "CloudWatchLogAccess"
          Effect = "Allow"
          Action = [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups"
          ]
          Resource = "*"
        },
        # Events for state machine execution
        {
          Sid    = "EventsAccess"
          Effect = "Allow"
          Action = [
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule",
          ]
          Resource = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule"
        }
      ]
    })
  ]

  tags = local.merged_tags
}

# CloudWatch Log Group for Step Function using PGE module
module "step_function_logs" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name              = "/aws/stepfunctions/arcgis-enterprise-amipipeline-orchestrator-${var.environment}"
  retention_in_days = 180
  kms_key_id        = module.cloudwatch_logs_kms.key_arn

  tags = merge(
    local.merged_tags,
    {
      Name = "arcgis-enterprise-amipipeline-orchestrator-${var.environment}-logs"
    }
  )
}

# Render State Machine Definition
locals {
  # Choose template based on test_mode
  state_machine_template = var.test_mode ? "${path.module}/step_functions/build_pipeline_test.json.tpl" : "${path.module}/step_functions/build_pipeline.json.tpl"

  state_machine_definition = templatefile(local.state_machine_template, {
    ami_writer_lambda_arn     = module.ami_writer_lambda.lambda_arn
    tfc_runner_lambda_arn     = module.tfc_runner_lambda.lambda_arn
    config_manager_lambda_arn = module.config_manager_lambda.lambda_arn
    tfc_workspace_path        = var.tfc_workspace_path
    account_id                = data.aws_caller_identity.current.account_id
    aws_region                = data.aws_region.current.region
    environment               = lower(var.environment)
  })
}

# Step Function State Machine using the module
module "arcgis-enterprise-amibuild_orchestrator" {
  source  = "app.terraform.io/pgetech/step-functions/aws"
  version = "0.1.4"

  state_machine_name       = "argis-enterprise-amibuild-pipeline-${var.environment}"
  state_machine_definition = local.state_machine_definition
  state_machine_role_arn   = module.step_function_iam_role.arn
  state_machine_type       = "STANDARD"

  include_execution_data        = true
  level                         = "ALL"
  log_destination               = module.step_function_logs.cloudwatch_log_group_arn
  tracing_configuration_enabled = true

  tags = local.merged_tags
}

################################################################################
# Outputs
################################################################################

output "step_function_arn" {
  value       = module.arcgis-enterprise-amibuild_orchestrator.state_machine_arn
  description = "ARN of the Step Function"
}

output "step_function_name" {
  value       = module.arcgis-enterprise-amibuild_orchestrator.state_machine_id
  description = "Name/ID of the Step Function"
}

output "step_function_role_arn" {
  value       = module.step_function_iam_role.arn
  description = "ARN of the Step Function IAM role"
}

output "step_function_log_group" {
  value       = module.step_function_logs.cloudwatch_log_group_name
  description = "CloudWatch Log Group for Step Function"
}
