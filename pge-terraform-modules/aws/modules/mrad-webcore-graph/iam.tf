# This role has 2 policies attached. One is custom designed
# and is called "neptune_proxy_taskdef_policy" in this code.
# The other is Amazon-managed and is called
# "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
resource "aws_iam_role" "neptune_svc_taskdef_role" {
  name               = "${var.prefix}-neptune-taskdef-${lower(var.suffix)}"
  assume_role_policy = data.aws_iam_policy_document.ecstasks_assume_role.json

  tags = var.tags
}

resource "aws_iam_policy" "neptune_poller_taskdef_policy" {
  name   = "${var.prefix}-neptune-poller-taskdef-${lower(var.suffix)}"
  tags   = var.tags
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "codepipeline:GetPipelineExecution",
        "acm:GetCertificate",
        "secretsmanager:GetSecretValue",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "kms:*",
        "ssmmessages:*",
        "neptune-db:List*",
        "neptune-db:Get*",
        "neptune-db:Read*",
        "neptune-db:WriteDataViaQuery",
        "neptune-db:DeleteDataViaQuery",
        "neptune-db:StartLoaderJob",
        "neptune-db:ResetDatabase",
        "neptune-db:connect",
        "neptune-db:CancelQuery",
        "neptune-db:CancelLoaderJob",
        "sqs:Get*",
        "sqs:*Queue*",
        "sqs:*Message*",
        "sns:List*",
        "sns:Get*",
        "sns:*Resource*",
        "sns:ConfirmSubscription",
        "sns:Publish",
        "sns:*scribe",
        "rds:Describe*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "neptune_poller_taskdef_role_policy" {
  role       = aws_iam_role.neptune_svc_taskdef_role.name
  policy_arn = aws_iam_policy.neptune_poller_taskdef_policy.arn
}

resource "aws_iam_role_policy_attachment" "neptune_poller_task_execution_role_policy" {
  role       = aws_iam_role.neptune_svc_taskdef_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
