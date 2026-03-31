# Assets bucket for pipeline source
module "assets_s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.4"

  bucket_name = "ami-factory-assets-${random_string.name_randamizer.result}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning  = "Enabled"
  kms_key_arn = module.codepipeline_artifacts_kms.key_arn

  tags = local.merged_tags
}

# Pipeline artifacts bucket
module "pipeline_artifacts_s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.4"

  bucket_name = "ami-factory-pipeline-artifacts-${random_string.name_randamizer.result}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  kms_key_arn = module.codepipeline_artifacts_kms.key_arn

  tags = local.merged_tags
}

# SNS topic for notifications with encryption and security
resource "aws_sns_topic" "pipeline_notifications" {
  name_prefix       = "ami-factory-pipeline-"
  display_name      = "AMI Factory Pipeline Notifications"
  kms_master_key_id = module.sns_encryption_kms.key_arn

  tags = local.merged_tags
}

# Create reference to SNS topic ARN for CodePipeline
locals {
  pipeline_notifications_arn = aws_sns_topic.pipeline_notifications.arn
}

# Create zip file of pipeline input
data "archive_file" "pipeline_input" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/pipeline-input.zip"

  source {
    content = jsonencode({
      # components = ["webadapter", "portal", "datastore", "server"]
      components = ["webadapter"]
    })
    filename = "input.json"
  }
}


# Upload zipped pipeline input to assets bucket
resource "aws_s3_object" "pipeline_input" {
  bucket = module.assets_s3.id
  key    = "pipeline/input.zip"
  source = data.archive_file.pipeline_input.output_path
  etag   = filemd5(data.archive_file.pipeline_input.output_path)

  tags = {
    AppID              = "APP-${var.app_id}"
    Environment        = var.environment
    DataClassification = var.data_classification
    CRIS               = var.cris
    Notify             = join("_", var.notify)
    Owner              = join("_", var.owner)
    Compliance         = join("_", var.compliance)
  }
}

# Create zip file of arcgis install scripts for iamge builder recipe
data "archive_file" "arcgis_install" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/arcgis-install-package.zip"

  source_dir = "${path.module}/arcgis_install_scripts/${var.arcgis_version}"
}

# Upload arcgis install scripts to assets bucket
resource "aws_s3_object" "arcgis_install" {
  bucket = module.assets_s3.id
  key    = "arcgis_install/arcgis-install-package.zip"
  source = data.archive_file.arcgis_install.output_path
  etag   = filemd5(data.archive_file.arcgis_install.output_path)

  tags = {
    AppID              = "APP-${var.app_id}"
    Environment        = var.environment
    DataClassification = var.data_classification
    CRIS               = var.cris
    Notify             = join("_", var.notify)
    Owner              = join("_", var.owner)
    Compliance         = join("_", var.compliance)
  }
}

# EventBridge rule to trigger pipeline on golden AMI parameter update
resource "aws_cloudwatch_event_rule" "golden_ami_updated" {
  name_prefix = "ami-factory-golden-ami-updated-"
  description = "Trigger AMI Factory pipeline when golden AMI parameter is updated"

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Parameter Store Change"]
    detail = {
      operation = ["Update"]
      name      = ["/ami/rhellinux/golden"]
    }
  })

  tags = merge(local.merged_tags, {
    Component = "pipeline"
  })
}

resource "aws_cloudwatch_event_target" "golden_ami_to_pipeline" {
  rule      = aws_cloudwatch_event_rule.golden_ami_updated.name
  target_id = "TriggerCodePipeline"
  arn       = aws_codepipeline.ami_factory.arn
  role_arn  = module.eventbridge_codepipeline_iam.arn
}

# IAM role for EventBridge to trigger CodePipeline
module "eventbridge_codepipeline_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-eventbridge-pipeline"
  description = "IAM role for EventBridge to trigger CodePipeline"
  aws_service = ["events.amazonaws.com"]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid    = "StartPipeline"
        Effect = "Allow"
        Action = [
          "codepipeline:StartPipelineExecution"
        ]
        Resource = aws_codepipeline.ami_factory.arn
      }]
    })
  ]

  tags = merge(local.merged_tags, {
    Component = "pipeline"
  })
}

# CodePipeline IAM role
module "codepipeline_iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-codepipeline"
  description = "IAM role for CodePipeline to orchestrate AMI factory"
  aws_service = ["codepipeline.amazonaws.com"]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "S3ObjectAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject*",
            "s3:PutObject*"
          ]
          Resource = [
            "${module.assets_s3.arn}/*",
            "${module.pipeline_artifacts_s3.arn}/*"
          ]
        },
        {
          Sid    = "S3BucketAccess"
          Effect = "Allow"
          Action = [
            "s3:ListBucket*",
            "s3:GetBucket*"
          ]
          Resource = [
            module.assets_s3.arn,
            module.pipeline_artifacts_s3.arn
          ]
        },
        {
          Sid    = "KMSAccess"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*"
          ]
          Resource = [
            module.codepipeline_artifacts_kms.key_arn
          ]

        },
        {
          Sid    = "StepFunctionsAccess"
          Effect = "Allow"
          Action = [
            "states:StartExecution",
            "states:ListExecutions",
            "states:DescribeStateMachine"
          ]
          Resource = [
            module.arcgis-enterprise-amibuild_orchestrator.state_machine_arn
          ]
        },
        {
          Sid    = "StepFunctionsExecutionAccess"
          Effect = "Allow"
          Action = [
            "states:GetExecutionHistory",
            "states:DescribeStateMachineForExecution",
            "states:DescribeExecution"
          ]
          Resource = [
            "${replace(module.arcgis-enterprise-amibuild_orchestrator.state_machine_arn, ":stateMachine:", ":execution:")}:*"
          ]
        },
        {
          Sid    = "StepFunctionsEvents"
          Effect = "Allow"
          Action = [
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule"
          ]
          Resource = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule"
        },
        {
          Sid    = "LambdaAccess"
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = [
            module.ami_publisher_lambda.lambda_arn,
            module.pipeline_input_preparer_lambda.lambda_arn,
            module.tfc_runner_lambda.lambda_arn
          ]
        },
        {
          Sid    = "SNSAccess"
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = [
            aws_sns_topic.pipeline_notifications.arn
          ]
        }
      ]
    })
  ]

  tags = merge(local.merged_tags, {
    Component = "pipeline"
  })
}

# CodePipeline
resource "aws_codepipeline" "ami_factory" {
  name          = "ami-factory-${var.environment}"
  role_arn      = module.codepipeline_iam.arn
  pipeline_type = "V2"

  variable {
    name          = "BUILD_WEBADAPTER"
    default_value = "FROM_CONFIG"
    description   = "Set to 'true' or 'false' to override. 'FROM_CONFIG' uses the S3 input.json."
  }

  variable {
    name          = "BUILD_PORTAL"
    default_value = "FROM_CONFIG"
    description   = "Set to 'true' or 'false' to override. 'FROM_CONFIG' uses the S3 input.json."
  }

  variable {
    name          = "BUILD_DATASTORE"
    default_value = "FROM_CONFIG"
    description   = "Set to 'true' or 'false' to override. 'FROM_CONFIG' uses the S3 input.json."
  }

  variable {
    name          = "BUILD_SERVER"
    default_value = "FROM_CONFIG"
    description   = "Set to 'true' or 'false' to override. 'FROM_CONFIG' uses the S3 input.json."
  }

  artifact_store {
    location = module.pipeline_artifacts_s3.id
    type     = "S3"

    encryption_key {
      id   = module.codepipeline_artifacts_kms.key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "S3Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "SourceVariables"

      configuration = {
        S3Bucket             = module.assets_s3.id
        S3ObjectKey          = "pipeline/input.zip"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "PrepareParameters"

    action {
      name             = "PrepareParameters"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["filtered_output"]
      namespace        = "PrepareParametersVariables"

      configuration = {
        FunctionName = element(split(":", module.pipeline_input_preparer_lambda.lambda_arn), 6)
        UserParameters = jsonencode({
          webadapter = "#{variables.BUILD_WEBADAPTER}"
          portal     = "#{variables.BUILD_PORTAL}"
          datastore  = "#{variables.BUILD_DATASTORE}"
          server     = "#{variables.BUILD_SERVER}"
        })
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "BuildAMIs"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "StepFunctions"
      version         = "1"
      input_artifacts = ["filtered_output"]

      configuration = {
        StateMachineArn = module.arcgis-enterprise-amibuild_orchestrator.state_machine_arn
        InputType       = "FilePath"
        Input           = "input.json"
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.pipeline_notifications.arn
        CustomData      = "Please review AMI builds and approve for publication"
      }
    }
  }

  stage {
    name = "Publish"

    action {
      name     = "PublishAMIs"
      category = "Invoke"
      owner    = "AWS"
      provider = "Lambda"
      version  = "1"

      configuration = {
        FunctionName = module.ami_publisher_lambda.lambda_all.function_name
      }
    }
  }

  tags = merge(local.merged_tags, {
    Component = "pipeline"
  })
}
