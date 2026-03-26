module "ssm_automation_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "${var.ssm_document_name}-automation-role"
  aws_service = ["ssm.amazonaws.com"]
  tags        = var.tags

}

# IAM Policy attached to the role
module "ssm_document_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name = "${var.ssm_document_name}-automation-policy"
  path = "/"
  policy = [jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "sns:Publish",
          "Kms:GenerateDataKey",
          "Kms:Encrypt",
          "Kms:Decrypt",
          "ssm:*",
          "ses:*",
          "cloudformation:DescribeStackSetOperation",
          "ec2:DescribeImages",
          "sns:*",
          "sns:Publish",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "ec2:DescribeImages",
          "ec2:ModifyImageAttribute",
          "cloudformation:UpdateStackSet",
          "cloudformation:DescribeStackSet",
          "cloudformation:DescribeStackSetOperation",
          "lambda:InvokeFunction",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"

        ]
        Resource = "*"
      }
    ]
  })]

  tags = var.tags
}

# Attach the policy to IAM role
resource "aws_iam_role_policy_attachment" "ssm_document_policy_attachment" {
  policy_arn = module.ssm_document_policy.arn
  role       = module.ssm_automation_role.name
}
# Update VR tags
locals {
  script_content = trim(jsonencode(file("${path.module}/ssm_automation_scripts/email_notification.py")), "\"")
}
resource "aws_ssm_document" "automation_document" {
  name          = "${var.ssm_document_name}-nonprod"
  document_type = "Automation"
  content = templatefile("${path.module}/ssm_automation_template.json.tpl", {
    AutomationAssumeRole          = module.ssm_automation_role.arn
    beta_ami_parameter_store      = data.aws_ssm_parameter.beta_ami_parameter.name
    ami_parameter_store           = data.aws_ssm_parameter.ami_parameter.name
    nonprod_ami_parameter_store   = data.aws_ssm_parameter.nonprod_ami_parameter.name
    prev_ami_parameter_store      = data.aws_ssm_parameter.prev_ami_parameter.name
    approver_arns                 = jsonencode(var.approver_arns)
    approver_topic_arn            = data.aws_ssm_parameter.approver_topic_arn.value
    update_stackset_function_name = module.update_stackset_lambda.lambda_arn
    stack_set_name                = var.stack_set_name
    email_notification_script     = local.script_content
    sender                        = var.sender
    recipient                     = join(",", var.receipients)
    environment = var.tags["Environment"]


  })
  tags = var.tags
}

module "lambda_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"
  name    = "SecurityGroup-Lambda-${var.ssm_document_name}"
  vpc_id  = data.aws_ssm_parameter.vpc_id.value

  # Egress rule allowing all outbound traffic
  cidr_egress_rules = [{
    description      = "Allow all outbound"
    from             = 0
    to               = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }]

  tags = local.module_tags
}
module "lambda_execution_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.ssm_document_name}-lambda-ssm-role"
  aws_service = ["lambda.amazonaws.com"]
  tags        = var.tags

}
module "lambda_function_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name = "${var.ssm_document_name}-lambda-policy"
  path = "/"
  policy = [jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "cloudformation:UpdateStackInstances",
          "cloudformation:ListStackInstances",
          "cloudformation:DescribeStackInstance",
          "cloudformation:UpdateStackSet",
          "cloudformation:DescribeStackSet",
          "cloudformation:DescribeStackSetOperation",
          "sns:Publish",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "ec2:CopyImage",
          "ec2:ModifyImageAttribute",
          "ssm:PutParameter"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:us-west-2:${data.aws_caller_identity.current.account_id}:table/${var.target_accounts_table}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })]

  tags = var.tags
}
# Attach the policy to  the IAM role
resource "aws_iam_role_policy_attachment" "automation_lambda_policy_attachment" {
  policy_arn = module.lambda_function_policy.arn
  role       = module.lambda_execution_role.name
}
module "update_stackset_lambda" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = "${var.ssm_document_name}-stackset-lambda"
  role          = module.lambda_execution_role.arn
  handler       = "update_stackset_lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  memory_size   = 256

  source_code = {
    source_dir = "${path.module}/src"
  }
  environment_variables = {
    variables = {
      TARGET_ACCOUNTS_TABLE  = var.target_accounts_table
      STACKSET_ACCOUNT_SETUP = var.stack_set_name
      KMS_ALIAS              = data.aws_ssm_parameter.cmk_ebs_arn.value
      ENCRYPTED_AMI_STORE    = data.aws_ssm_parameter.encrypted_ami_parameter.name
      BETA_AMI_STORE         = data.aws_ssm_parameter.beta_ami_parameter.name
    }
    kms_key_arn = data.aws_ssm_parameter.cmk_arn.value
  }
  vpc_config_security_group_ids = [module.lambda_security_group.sg_id]
  vpc_config_subnet_ids = [data.aws_ssm_parameter.subnet_id_az_a.value,
    data.aws_ssm_parameter.subnet_id_az_b.value,
  data.aws_ssm_parameter.subnet_id_az_c.value]
  tags = var.tags
}
locals {
  prod_update_stackset_script_1 = trim(jsonencode(file("${path.module}/ssm_automation_scripts/prod_update_stackset_1.py")), "\"")
  prod_update_stackset_script_2 = trim(jsonencode(file("${path.module}/ssm_automation_scripts/prod_update_stackset_2.py")), "\"")
  prod_update_stackset_script_3 = trim(jsonencode(file("${path.module}/ssm_automation_scripts/prod_update_stackset_3.py")), "\"")
}
resource "aws_ssm_document" "automation_document_prod" {
  name          = "${var.ssm_document_name}-prod"
  document_type = "Automation"
  content = templatefile("${path.module}/ssm_automation_prod_template.json.tpl", {
    AutomationAssumeRole          = module.ssm_automation_role.arn
    beta_ami_parameter_store      = data.aws_ssm_parameter.beta_ami_parameter.name
    ami_parameter_store           = data.aws_ssm_parameter.ami_parameter.name
    nonprod_ami_parameter_store   = data.aws_ssm_parameter.nonprod_ami_parameter.name
    prev_ami_parameter_store      = data.aws_ssm_parameter.prev_ami_parameter.name
    encrypted_beta_ami_parameter_store    = data.aws_ssm_parameter.encrypted_ami_parameter.name
    encrypted_ami_parameter_store    = data.aws_ssm_parameter.encrypted_ami_parameter_main.name
    approver_arns                 = jsonencode(var.approver_arns)
    approver_topic_arn            = data.aws_ssm_parameter.approver_topic_arn.value
    update_stackset_function_name = module.update_stackset_lambda.lambda_arn
    stack_set_name                = var.stack_set_name
    prod_update_stackset_script_1     = local.prod_update_stackset_script_1
    prod_update_stackset_script_2     = local.prod_update_stackset_script_2
    prod_update_stackset_script_3     = local.prod_update_stackset_script_3     
    sender                        = var.sender
    recipient                     = join(",", var.receipients)
    environment = var.tags["Environment"]


  })
  tags = var.tags
}