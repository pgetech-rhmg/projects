module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#####################################################
# Creating SSM-Document in YAML Format
#####################################################
module "ssm_configure_portal" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_portal_config_document_name
  ssm_document_type    = var.ssm_command_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm-configure-arcgis-portal.yml")

  tags = module.tags.tags
}

module "ssm_install_enterprise_patches" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_enterprise_install_patch_document_name
  ssm_document_type    = var.ssm_command_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm-install-arcgis-enterprise-patches.yml")

  tags = module.tags.tags
}

module "ssm_install_enterprise_license" {
  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"
  # insert required variables here

  ssm_document_name    = var.ssm_enterprise_install_license_document_name
  ssm_document_type    = var.ssm_command_document_type
  ssm_document_format  = var.ssm_document_format
  ssm_document_content = file("${path.module}/scripts/ssm-install-arcgis-enterprise-license.yml")

  tags = module.tags.tags
}

#####################################################
# IAM Role for SSM Automation Execution
#####################################################
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ssm_automation_role" {
  name = "SSM-Automation-ExecutionRole-ArcGIS-Patches"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = module.tags.tags
}

resource "aws_iam_role_policy" "ssm_automation_policy" {
  name = "SSM-Automation-Policy-ArcGIS-Patches"
  role = aws_iam_role.ssm_automation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetAutomationExecution",
          "ssm:StartAutomationExecution",
          "ssm:StopAutomationExecution"
        ]
        Resource = "*"
      }
    ]
  })
}
