# IAM Role for EC2 Image Builder Instance
resource "aws_iam_role" "imagebuilder_instance_role" {
  name = "ArcGIS-WebAdaptor-ImageBuilder-InstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
        }
      }
    ]
  })

  tags = module.tags.tags
}

# Custom IAM Policy for ArcGIS Web Adaptor Installation
resource "aws_iam_role_policy" "imagebuilder_custom_policy" {
  name = "ArcGIS-WebAdaptor-ImageBuilder-CustomPolicy"
  role = aws_iam_role.imagebuilder_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.deployment_bucket}",
          "arn:aws:s3:::${var.deployment_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:PutParameter"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      },{
            "Action": [
                "secretsmanager:GetSecretValue",
                "ec2:CreateTags",
                "ssm:PutParameter",
                "ssm:GetParameter"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "kms:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },{
            "Action": "s3:GetObject",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::ccoe-patchpolicy-manage-all*",
            "Sid": "Allow"
        }
    ]
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "imagebuilder_instance_profile_policy" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_instance_profile_for_image_builder_ecr_container_builds" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

resource "aws_iam_role_policy_attachment" "imagebuilder_full_access" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSImageBuilderFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.imagebuilder_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "imagebuilder_instance_profile" {
  name = local.instance_profile_name
  role = aws_iam_role.imagebuilder_instance_role.name

  tags = module.tags.tags
}

# IAM Role for Image Builder Service
resource "aws_iam_role" "imagebuilder_service_role" {
  name = "ArcGIS-WebAdaptor-ImageBuilder-ServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "imagebuilder.amazonaws.com"
        }
      }
    ]
  })

  tags = module.tags.tags
}

# Attach AWS managed policy for Image Builder service role
resource "aws_iam_role_policy_attachment" "imagebuilder_service_role_policy" {
  role       = aws_iam_role.imagebuilder_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForImageBuilder"
}