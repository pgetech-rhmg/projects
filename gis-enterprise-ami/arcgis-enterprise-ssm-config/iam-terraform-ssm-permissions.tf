# IAM policy for Terraform role to execute SSM commands

# Data source for existing Terraform execution role
data "aws_iam_role" "tfc_role" {
  name = var.tfc_role_name
}

# SSM permissions policy for Terraform execution
resource "aws_iam_role_policy" "terraform_ssm_permissions" {
  name = "terraform-ssm-send-command-policy"
  role = data.aws_iam_role.tfc_role.id

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
          "secretsmanager:GetSecretValue",
          "iam:GetRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Output the role ARN for verification
output "terraform_role_arn" {
  description = "Terraform execution role ARN"
  value       = data.aws_iam_role.tfc_role.arn
}