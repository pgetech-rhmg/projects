# IAM policy for Terraform role to execute SSM commands

# Data source for existing Terraform execution role
data "aws_iam_role" "tfc_role" {
  name = var.tfc_role  # Your Terraform Cloud role
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
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation"
        ]
        Resource = [
          "arn:aws:ssm:*:*:document/arcgis-*",  # Your SSM documents
          "arn:aws:ec2:*:*:instance/*"          # All EC2 instances
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeDocumentParameters",
          "ssm:GetDocument"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
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