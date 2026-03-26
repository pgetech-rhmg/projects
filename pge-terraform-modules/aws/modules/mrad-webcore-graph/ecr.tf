resource "aws_ecr_repository" "neptune_poller" {
  name                 = "${var.prefix}-neptune-poller-${lower(var.suffix)}"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.neptune_ecr.arn
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "neptune_poller" {
  repository = aws_ecr_repository.neptune_poller.name
  policy     = data.aws_iam_policy_document.ecr_repo_policy.json
}

resource "aws_ecr_lifecycle_policy" "neptune_poller" {
  repository = aws_ecr_repository.neptune_poller.name
  policy     = <<EOF
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

data "aws_iam_policy_document" "ecr_repo_policy" {
  source_policy_documents = [
    templatefile(
      "${path.module}/templates/ecr_repo_policy.json.tmpl",
      { principal_orgid = local.principal_orgid }
  )]
}

resource "aws_ecr_repository" "graph_consumer" {
  name                 = "${var.prefix}-graph-consumer-${lower(var.suffix)}"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.neptune_ecr.arn
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "graph_consumer" {
  repository = aws_ecr_repository.graph_consumer.name
  policy     = data.aws_iam_policy_document.ecr_repo_policy.json
}

resource "aws_ecr_lifecycle_policy" "graph_consumer" {
  repository = aws_ecr_repository.graph_consumer.name
  policy     = <<EOF
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
