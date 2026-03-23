###############################################################################
# Tags
###############################################################################

module "tags" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-tags.git?ref=main"

  aws_account_id     = var.aws_account_id
  environment        = var.environment
  appid              = var.appid
  compliance         = var.compliance
  cris               = var.cris
  dataclassification = var.dataclassification
  notify             = var.notify
  order              = var.order
  owner              = var.owner
}


###############################################################################
# Random suffix for globally unique S3 bucket names
###############################################################################

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}


###############################################################################
# KMS — AMI Encryption
###############################################################################

resource "aws_kms_key" "amis" {
  description             = "ami-factory-amis-${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = module.tags.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAdmin"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowImageBuilder"
        Effect = "Allow"
        Principal = {
          Service = ["imagebuilder.amazonaws.com", "ec2.amazonaws.com"]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCrossAccountAMIUse"
        Effect = "Allow"
        Principal = {
          AWS = [for id in var.share_account_ids : "arn:aws:iam::${id}:root"]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "amis" {
  name          = "alias/ami-factory-amis-${var.environment}"
  target_key_id = aws_kms_key.amis.key_id
}


###############################################################################
# KMS — CloudWatch Logs
###############################################################################

resource "aws_kms_key" "logs" {
  description             = "ami-factory-cloudwatch-logs-${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = module.tags.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAdmin"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/ami-factory-cloudwatch-logs-${var.environment}"
  target_key_id = aws_kms_key.logs.key_id
}


###############################################################################
# S3 — Image Builder Logs
###############################################################################

resource "aws_s3_bucket" "image_builder_logs" {
  bucket        = "ami-factory-imagebuilder-logs-${random_string.suffix.result}"
  force_destroy = false
  tags          = module.tags.tags
}

resource "aws_s3_bucket_public_access_block" "image_builder_logs" {
  bucket                  = aws_s3_bucket.image_builder_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "image_builder_logs" {
  bucket = aws_s3_bucket.image_builder_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_ssm_parameter.enterprise_kms.value
    }
  }
}


###############################################################################
# S3 — ESRI Assets (install scripts)
###############################################################################

resource "aws_s3_bucket" "esri_assets" {
  bucket        = "ami-factory-assets-${random_string.suffix.result}"
  force_destroy = false
  tags          = module.tags.tags
}

resource "aws_s3_bucket_public_access_block" "esri_assets" {
  bucket                  = aws_s3_bucket.esri_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "esri_assets" {
  bucket = aws_s3_bucket.esri_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_ssm_parameter.enterprise_kms.value
    }
  }
}


###############################################################################
# Security Group — Image Builder Instances
###############################################################################

resource "aws_security_group" "image_builder" {
  name        = "ami-factory-imagebuilder-sg"
  description = "Security group for Image Builder instances"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  tags        = module.tags.tags

  egress {
    description = "HTTPS outbound (package repos)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP outbound (package repos)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


###############################################################################
# IAM — Image Builder Instance Role
###############################################################################

resource "aws_iam_role" "image_builder" {
  name = "ami-factory-image-builder-${var.environment}"
  tags = module.tags.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "image_builder_ssm" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "image_builder_ec2" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy" "image_builder_custom" {
  name = "ami-factory-image-builder-custom"
  role = aws_iam_role.image_builder.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.amis.arn,
          data.aws_ssm_parameter.enterprise_kms.value
        ]
      },
      {
        Sid    = "S3AssetAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.esri_assets.arn,
          "${aws_s3_bucket.esri_assets.arn}/*"
        ]
      },
      {
        Sid    = "S3LogAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.image_builder_logs.arn}/*"
        ]
      },
      {
        Sid    = "SecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:jfrog/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "ami-factory-image-builder-${var.environment}"
  role = aws_iam_role.image_builder.name
  tags = module.tags.tags
}


###############################################################################
# SSM Parameter — AMI KMS Key ARN (for downstream consumers)
###############################################################################

resource "aws_ssm_parameter" "ami_kms_key" {
  name        = "/amifactory/kms/keyarn"
  type        = "String"
  value       = aws_kms_key.amis.arn
  description = "KMS key ARN for AMI encryption"
  tags        = module.tags.tags
}


###############################################################################
# Image Builder Pipelines
###############################################################################

module "image_builder" {
  source   = "./modules/image-builder-pipeline"
  for_each = toset(var.components)

  component_name        = each.value
  environment           = var.environment
  source_ami_id         = var.source_ami_id
  instance_types        = var.instance_types
  instance_profile_name = aws_iam_instance_profile.image_builder.name
  kms_key_arn           = aws_kms_key.amis.arn
  share_account_ids     = var.share_account_ids
  log_bucket            = aws_s3_bucket.image_builder_logs.id
  security_group_id     = aws_security_group.image_builder.id
  subnet_id             = local.builder_subnet_id
  esri_assets_bucket    = var.esri_assets_bucket
  ebs_volume_size       = lookup(var.ebs_volume_sizes, each.value, "30")
  tags                  = module.tags.tags
}
