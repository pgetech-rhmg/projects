# Shared resources
module "image_builder_logs_s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.4"

  bucket_name = "ami-factory-imagebuilder-logs-${random_string.name_randamizer.result}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.merged_tags
}

module "image_builder_sg" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "ami-factory-imagebuilder-sg"
  description = "Security group for EC2 Image Builder instances"

  cidr_egress_rules = [
    {
      from             = 443
      to               = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow HTTPS for AWS services and package repositories"
    },
    {
      from             = 80
      to               = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "Allow HTTP for package repositories"
    }
  ]

  cidr_ingress_rules = []

  tags = local.merged_tags
}

# Render component YAML templates
locals {
  component_configs = {
    webadapter = {
      name                 = "webadapter"
      source_bucket        = module.assets_s3.id
      esri_assets_location = var.esri_assets_location
    }
    portal = {
      name                 = "portal"
      source_bucket        = module.assets_s3.id
      esri_assets_location = var.esri_assets_location
    }
    datastore = {
      name                 = "datastore"
      source_bucket        = module.assets_s3.id
      esri_assets_location = var.esri_assets_location
    }
    server = {
      name                 = "server"
      source_bucket        = module.assets_s3.id
      esri_assets_location = var.esri_assets_location
    }
  }

  rendered_yamls = {
    for key, config in local.component_configs :
    key => templatefile("${path.module}/templates/component_installer.yaml.tpl", {
      component_name       = config.name
      source_bucket        = config.source_bucket
      esri_source_location = config.esri_assets_location
    })
  }

  rendered_test_yamls = {
    for component, config in local.component_configs :
    component => templatefile("${path.module}/templates/${component}_test.yaml.tpl", config)
  }
}

# IAM role for Image Builder
module "ami-factory-image-builder-iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "ami-factory-image-builder"
  description = "IAM role for AMI builder components"
  aws_service = ["ec2.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policy = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "KMSEncryptionPermissions"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:GenerateDataKey*",
            "kms:ReEncrypt*",
            "kms:CreateGrant"
          ]
          Resource = [
            module.ami_encryption_kms.key_arn,
            data.aws_ssm_parameter.enterprise_kms.value
          ]
        },
        {
          Sid    = "SecretsAccess"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:jfrog/*"
        },        
        {
          Sid    = "S3ComponentAndLoggingAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ]
          Resource = ["*"]
        },
        {
          Sid      = "LogBucketAccess"
          Effect   = "Allow"
          Action   = ["s3:PutObject"]
          Resource = ["arn:aws:s3:::${module.image_builder_logs_s3.id}/*"]
        }
      ]
    })
  ]

  tags = local.merged_tags
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "ami-factory-image-builder-instance-profile"
  role = module.ami-factory-image-builder-iam.name

  tags = merge(local.merged_tags, {
    Component = "image-builder"
  })
}

# Create image builder pipelines for each component
module "image_builder_webadapter" {
  source = "./modules/image-builder-pipeline"

  component_name        = "webadapter"
  recipe_version        = "1.0.2"
  component_version     = "1.0.0"
  environment           = var.environment
  base_ami_name_filter  = var.base_ami_name_filter
  installer_yaml        = local.rendered_yamls["webadapter"]
  test_yaml             = local.rendered_test_yamls["webadapter"]
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  kms_key_arn           = module.ami_encryption_kms.key_arn
  share_account_ids     = var.share_account_ids
  log_bucket            = module.image_builder_logs_s3.id
  security_group_id     = module.image_builder_sg.sg_id
  subnet_id             = data.aws_ssm_parameter.subnet_id1.value
  instance_types        = var.instance_types
  source_ami_id         = data.aws_ssm_parameter.rhellinux_golden_ami.value
  tags                  = local.merged_tags
}

module "image_builder_portal" {
  source = "./modules/image-builder-pipeline"

  component_name        = "portal"
  recipe_version        = "1.0.2"
  component_version     = "1.0.0"
  environment           = var.environment
  base_ami_name_filter  = var.base_ami_name_filter
  installer_yaml        = local.rendered_yamls["portal"]
  test_yaml             = local.rendered_test_yamls["portal"]
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  kms_key_arn           = module.ami_encryption_kms.key_arn
  share_account_ids     = var.share_account_ids
  log_bucket            = module.image_builder_logs_s3.id
  security_group_id     = module.image_builder_sg.sg_id
  subnet_id             = data.aws_ssm_parameter.subnet_id1.value
  instance_types        = var.instance_types
  ebs_volume_size       = "60"
  source_ami_id         = data.aws_ssm_parameter.rhellinux_golden_ami.value
  tags                  = local.merged_tags
}

module "image_builder_datastore" {
  source = "./modules/image-builder-pipeline"

  component_name        = "datastore"
  recipe_version        = "1.0.2"
  component_version     = "1.0.0"
  environment           = var.environment
  base_ami_name_filter  = var.base_ami_name_filter
  installer_yaml        = local.rendered_yamls["datastore"]
  test_yaml             = local.rendered_test_yamls["datastore"]
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  kms_key_arn           = module.ami_encryption_kms.key_arn
  share_account_ids     = var.share_account_ids
  log_bucket            = module.image_builder_logs_s3.id
  security_group_id     = module.image_builder_sg.sg_id
  subnet_id             = data.aws_ssm_parameter.subnet_id1.value
  instance_types        = var.instance_types
  source_ami_id         = data.aws_ssm_parameter.rhellinux_golden_ami.value
  tags                  = local.merged_tags
}

module "image_builder_server" {
  source = "./modules/image-builder-pipeline"

  component_name        = "server"
  recipe_version        = "1.0.2"
  component_version     = "1.0.0"
  environment           = var.environment
  base_ami_name_filter  = var.base_ami_name_filter
  installer_yaml        = local.rendered_yamls["server"]
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  test_yaml             = local.rendered_test_yamls["server"]
  kms_key_arn           = module.ami_encryption_kms.key_arn
  share_account_ids     = var.share_account_ids
  log_bucket            = module.image_builder_logs_s3.id
  security_group_id     = module.image_builder_sg.sg_id
  subnet_id             = data.aws_ssm_parameter.subnet_id1.value
  instance_types        = var.instance_types
  source_ami_id         = data.aws_ssm_parameter.rhellinux_golden_ami.value
  tags                  = local.merged_tags
}


