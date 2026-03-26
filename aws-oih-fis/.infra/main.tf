###############################################################################
# Locals
###############################################################################
locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
}

###############################################################################
# PG&E Tags
###############################################################################
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

###############################################################################
# S3 Bucket — FIS Experiment Logs
###############################################################################
module "fis_logs_bucket" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.0"
  bucket_name = var.s3_bucket_name
  kms_key_arn = null
  tags        = merge(module.tags.tags, local.optional_tags)

  policy = templatefile("${path.module}/templates/fis_s3_bucket_policy.json", {
    bucket_name = var.s3_bucket_name
  })
}

###############################################################################
# CloudWatch Log Group — FIS Experiments
###############################################################################
resource "aws_cloudwatch_log_group" "fis_experiments" {
  name              = "/aws/fis/experiments"
  retention_in_days = 30
  tags              = merge(module.tags.tags, local.optional_tags)
}

###############################################################################
# SSM Parameters — AZ Configuration
###############################################################################
resource "aws_ssm_parameter" "fis_primary_az" {
  name  = "/fis/oih/primary-az"
  type  = "String"
  value = var.primary_az
  tags = merge(module.tags.tags, local.optional_tags, {
    Name = "FIS-OIH-PrimaryAZ"
  })
}

resource "aws_ssm_parameter" "fis_secondary_az" {
  name  = "/fis/oih/secondary-az"
  type  = "String"
  value = var.secondary_az
  tags = merge(module.tags.tags, local.optional_tags, {
    Name = "FIS-OIH-SecondaryAZ"
  })
}

resource "aws_ssm_parameter" "fis_tertiary_az" {
  name  = "/fis/oih/tertiary-az"
  type  = "String"
  value = var.tertiary_az
  tags = merge(module.tags.tags, local.optional_tags, {
    Name = "FIS-OIH-TertiaryAZ"
  })
}

###############################################################################
# FIS Experiment — Primary EC2 Stop
#
# First experiment creates the shared IAM role (fis_role_name = "").
# All subsequent experiments reference the role by name.
###############################################################################
module "fis_primary_ec2_stop" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Primary-EC2-Stop"
  description         = "Stop Primary SQL Server instances and auto-restart after 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-EC2-Stop" })
  fis_role_name       = ""

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "primaryDBInstances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISDBRole", value = "Primary" }
    ]
    filter = [{ path = "State.Name", values = ["running"] }]
  }]

  action = [{
    name        = "stopInstances"
    action_id   = "aws:ec2:stop-instances"
    description = "Stop primary SQL Server instances with auto-restart"
    parameter   = { startInstancesAfterDuration = "PT5M" }
    target      = [{ key = "Instances", value = "primaryDBInstances" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/primary-ec2-stop" }
  cloudwatch_log_group_name = ""
}

###############################################################################
# FIS Experiment — Secondary EC2 Stop
###############################################################################
module "fis_secondary_ec2_stop" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Secondary-EC2-Stop"
  description         = "Stop Secondary SQL Server instances and auto-restart after 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-EC2-Stop" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "secondaryDBInstances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISDBRole", value = "Secondary" }
    ]
    filter = [{ path = "State.Name", values = ["running"] }]
  }]

  action = [{
    name        = "stopInstances"
    action_id   = "aws:ec2:stop-instances"
    description = "Stop secondary SQL Server instances with auto-restart"
    parameter   = { startInstancesAfterDuration = "PT5M" }
    target      = [{ key = "Instances", value = "secondaryDBInstances" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/secondary-ec2-stop" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
# FIS Experiment — Primary EBS I/O Pause
###############################################################################
module "fis_primary_ebs_io_pause" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Primary-EBS-IO-Pause"
  description         = "Pause I/O on EBS volumes attached to Primary SQL Server for 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-EBS-IO-Pause" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "primaryDBVolumes"
    resource_type  = "aws:ec2:ebs-volume"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISEBSTarget", value = "True" },
      { key = "FISDBRole", value = "Primary" }
    ]
    parameters = { availabilityZoneIdentifier = var.primary_az }
  }]

  action = [{
    name        = "pauseVolumeIO"
    action_id   = "aws:ebs:pause-volume-io"
    description = "Pause EBS I/O on primary SQL Server volumes"
    parameter   = { duration = "PT5M" }
    target      = [{ key = "Volumes", value = "primaryDBVolumes" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/primary-ebs-io-pause" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
# FIS Experiment — Secondary EBS I/O Pause
###############################################################################
module "fis_secondary_ebs_io_pause" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Secondary-EBS-IO-Pause"
  description         = "Pause I/O on EBS volumes attached to Secondary SQL Server for 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-EBS-IO-Pause" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "secondaryDBVolumes"
    resource_type  = "aws:ec2:ebs-volume"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISEBSTarget", value = "True" },
      { key = "FISDBRole", value = "Secondary" }
    ]
    parameters = { availabilityZoneIdentifier = var.secondary_az }
  }]

  action = [{
    name        = "pauseVolumeIO"
    action_id   = "aws:ebs:pause-volume-io"
    description = "Pause EBS I/O on secondary SQL Server volumes"
    parameter   = { duration = "PT5M" }
    target      = [{ key = "Volumes", value = "secondaryDBVolumes" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/secondary-ebs-io-pause" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
# FIS Experiment — Subnet Disruption: Primary AZ
###############################################################################
module "fis_subnet_disrupt_primary_az" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Subnet-Disrupt-Primary-AZ"
  description         = "Simulate AZ failure — disrupt all network traffic to Primary AZ subnets for 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-AZ-Failure" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "primaryAZSubnets"
    resource_type  = "aws:ec2:subnet"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISAZRole", value = "Primary" }
    ]
  }]

  action = [{
    name        = "disruptConnectivity"
    action_id   = "aws:network:disrupt-connectivity"
    description = "Disrupt all network connectivity to primary AZ subnets"
    parameter   = { duration = "PT5M", scope = "all" }
    target      = [{ key = "Subnets", value = "primaryAZSubnets" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/primary-az-subnet-disrupt" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
# FIS Experiment — Subnet Disruption: Secondary AZ
###############################################################################
module "fis_subnet_disrupt_secondary_az" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Subnet-Disrupt-Secondary-AZ"
  description         = "Simulate AZ failure — disrupt all network traffic to Secondary AZ subnets for 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-AZ-Failure" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "secondaryAZSubnets"
    resource_type  = "aws:ec2:subnet"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISAZRole", value = "Secondary" }
    ]
  }]

  action = [{
    name        = "disruptConnectivity"
    action_id   = "aws:network:disrupt-connectivity"
    description = "Disrupt all network connectivity to secondary AZ subnets"
    parameter   = { duration = "PT5M", scope = "all" }
    target      = [{ key = "Subnets", value = "secondaryAZSubnets" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/secondary-az-subnet-disrupt" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
# FIS Experiment — Subnet Disruption: Tertiary AZ
###############################################################################
module "fis_subnet_disrupt_tertiary_az" {
  source              = "app.terraform.io/pgetech/fis/aws"
  fis_experiment_name = "OIH-Subnet-Disrupt-Tertiary-AZ"
  description         = "Simulate AZ failure — disrupt all network traffic to Tertiary AZ subnets (no DB servers) for 5 minutes"
  tags                = merge(module.tags.tags, local.optional_tags, { TestType = "HA-DR-AZ-Failure" })
  fis_role_name       = "fis-role-OIH-Primary-EC2-Stop"

  experiment_options = {
    account_targeting            = "single-account"
    empty_target_resolution_mode = "fail"
  }

  stop_condition = [{ source = "none", value = "" }]

  target = [{
    name           = "tertiaryAZSubnets"
    resource_type  = "aws:ec2:subnet"
    selection_mode = "ALL"
    resource_tags = [
      { key = "FISTarget", value = "True" },
      { key = "FISAZRole", value = "Tertiary" }
    ]
  }]

  action = [{
    name        = "disruptConnectivity"
    action_id   = "aws:network:disrupt-connectivity"
    description = "Disrupt all network connectivity to tertiary AZ subnets"
    parameter   = { duration = "PT5M", scope = "all" }
    target      = [{ key = "Subnets", value = "tertiaryAZSubnets" }]
  }]

  log_type                  = "s3"
  s3_bucket_name            = module.fis_logs_bucket.id
  validate_s3_bucket        = false
  s3_logging                = { prefix = "experiments/tertiary-az-subnet-disrupt" }
  cloudwatch_log_group_name = ""

  depends_on = [module.fis_primary_ec2_stop]
}

###############################################################################
###############################################################################
# TEST HARNESS
#
# Temporary infrastructure for validating FIS network disruption isolation.
# Deploys into an isolated AZ-D subnet.
###############################################################################
###############################################################################

###############################################################################
# Test Harness — Security Group
###############################################################################
module "test_harness_sg" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  name        = "FIS-Test-Harness-SG"
  description = "Security group for FIS test harness resources"
  vpc_id      = var.vpc_id
  tags        = merge(module.tags.tags, local.optional_tags, { Purpose = "FIS-Test-Harness" })

  cidr_ingress_rules = [
    {
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "HTTPS for API Gateway testing"
    },
    {
      from             = -1
      to               = -1
      protocol         = "icmp"
      cidr_blocks      = [var.test_subnet_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "ICMP within test subnet"
    }
  ]

  cidr_egress_rules = [
    {
      from             = 0
      to               = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow all outbound"
    }
  ]
}

###############################################################################
# Test Harness — IAM Role for Lambda
###############################################################################
module "test_lambda_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = "FIS-Test-Lambda-Role"
  aws_service = ["lambda.amazonaws.com"]
  tags        = merge(module.tags.tags, local.optional_tags, { Purpose = "FIS-Test-Harness" })

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  inline_policy = [jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:${var.aws_region}:${var.account_num}:log-group:/aws/lambda/FIS-Test-*"
    }]
  })]
}

###############################################################################
# Test Harness — VPC Lambda (will be isolated during disruption)
###############################################################################
module "test_vpc_lambda" {
  source        = "app.terraform.io/pgetech/lambda/aws"
  function_name = "FIS-Test-VPC-Lambda"
  description   = "VPC-attached Lambda to test network disruption isolation"
  runtime       = "python3.11"
  handler       = "index.lambda_handler"
  role          = module.test_lambda_role.arn
  timeout       = 10
  tags          = merge(module.tags.tags, local.optional_tags, { Purpose = "FIS-Test-Harness", IsolationTest = "VPC-Attached" })

  source_code = {
    content  = file("${path.module}/templates/vpc_lambda.py")
    filename = "index.py"
  }

  vpc_config_subnet_ids         = [var.test_subnet_id]
  vpc_config_security_group_ids = [module.test_harness_sg.id]
}

###############################################################################
# Test Harness — Regional Lambda (control — should NOT be affected)
###############################################################################
module "test_regional_lambda" {
  source        = "app.terraform.io/pgetech/lambda/aws"
  function_name = "FIS-Test-Regional-Lambda"
  description   = "Regional Lambda (no VPC) — should remain accessible during disruption"
  runtime       = "python3.11"
  handler       = "index.lambda_handler"
  role          = module.test_lambda_role.arn
  timeout       = 10
  tags          = merge(module.tags.tags, local.optional_tags, { Purpose = "FIS-Test-Harness", IsolationTest = "Regional-Control" })

  source_code = {
    content  = file("${path.module}/templates/regional_lambda.py")
    filename = "index.py"
  }

  vpc_config_subnet_ids         = []
  vpc_config_security_group_ids = []
}

###############################################################################
# Test Harness — CloudWatch Log Groups for Lambda
###############################################################################
resource "aws_cloudwatch_log_group" "test_vpc_lambda" {
  name              = "/aws/lambda/FIS-Test-VPC-Lambda"
  retention_in_days = 7
  tags              = merge(module.tags.tags, local.optional_tags)
}

resource "aws_cloudwatch_log_group" "test_regional_lambda" {
  name              = "/aws/lambda/FIS-Test-Regional-Lambda"
  retention_in_days = 7
  tags              = merge(module.tags.tags, local.optional_tags)
}

###############################################################################
# Test Harness — IAM Role for EC2
###############################################################################
module "test_ec2_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = "FIS-Test-EC2-Role"
  aws_service = ["ec2.amazonaws.com"]
  tags        = merge(module.tags.tags, local.optional_tags, { Purpose = "FIS-Test-Harness" })

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

###############################################################################
# Test Harness — EC2 Instance
###############################################################################
data "aws_ssm_parameter" "latest_amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

module "test_ec2" {
  source            = "app.terraform.io/pgetech/ec2/aws"
  name              = "FIS-Test-Harness-EC2"
  ami               = data.aws_ssm_parameter.latest_amazon_linux_2.value
  instance_type     = "t3.micro"
  availability_zone = "${var.aws_region}d"
  subnet_id         = var.test_subnet_id
  tags = merge(module.tags.tags, local.optional_tags, {
    Purpose   = "FIS-Test-Harness"
    FISTarget = "False"
  })

  vpc_security_group_ids = [module.test_harness_sg.id]
  instance_profile_role  = module.test_ec2_role.name

  metadata_http_endpoint = "enabled"

  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "<html><body><h1>FIS Test Harness</h1><p>Host: $(hostname)</p><p>Status: Running</p><p>Time: $(date)</p></body></html>" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  root_block_device = [{
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }]
}
