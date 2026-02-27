############################################
# Data
############################################

data "aws_iam_policy_document" "assume_role" {
  count = var.iam.create_instance_profile ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
