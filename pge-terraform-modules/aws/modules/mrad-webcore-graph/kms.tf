# Key Management System

# Naming convention: $identifier_$type

resource "aws_kms_key" "neptune_db" {
  description             = "Neptune encryption-at-rest key"
  deletion_window_in_days = 21
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key" "neptune_ecr" {
  description             = "ECR encryption-at-rest key"
  deletion_window_in_days = 21
  enable_key_rotation     = true
  tags                    = var.tags
}
