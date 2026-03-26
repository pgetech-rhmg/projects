resource "aws_ecr_repository" "ecr_repository" {
  name         = "${local.prefix}-${lower(local.short_name)}-${local.suffix}"
  tags         = var.tags
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_key.ecr.arn
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_repository_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last ${local.ecr_image_retention} tagged images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${local.ecr_image_retention}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# applied by the aws_ecr_repository_policy resource below
data "aws_iam_policy_document" "ecr_repository" {
  override_policy_documents = [
    templatefile(
      "${path.module}/templates/ecr_policy.json",
      { principal_orgid = local.principal_orgid }
  )]
}

resource "aws_ecr_repository_policy" "ecr_repository" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = data.aws_iam_policy_document.ecr_repository.json
}
