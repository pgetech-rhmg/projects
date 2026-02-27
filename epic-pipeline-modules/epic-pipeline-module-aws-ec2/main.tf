###############################################################################
# IAM Role (optional creation)
###############################################################################

resource "aws_iam_role" "this" {
  count = var.iam.create_instance_profile ? 1 : 0

  name               = "pge-epic-${var.app_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = merge(var.tags, {
    Name = "pge-epic-${var.app_name}-${var.environment}-role"
  })
}

resource "aws_iam_role_policy_attachment" "default_ssm" {
  count = var.iam.create_instance_profile ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = var.iam.create_instance_profile ? {
    for idx, arn in var.iam.policy_arns :
    idx => arn
  } : {}

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.iam.create_instance_profile ? 1 : 0

  name = "pge-epic-${var.app_name}-${var.environment}-instance-profile"
  role = aws_iam_role.this[0].name
  tags = merge(var.tags, {
    Name = "pge-epic-${var.app_name}-${var.environment}-profile"
  })
}


###############################################################################
# EC2 Instance
###############################################################################

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id              = var.network.subnet_id
  vpc_security_group_ids = var.network.security_group_ids

  iam_instance_profile = var.iam.create_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam.role_name

  user_data = var.user_data

  monitoring              = true
  ebs_optimized           = true
  disable_api_termination = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_size = var.root_volume.size
    volume_type = var.root_volume.type
    encrypted   = true
    kms_key_id  = try(var.root_volume.kms_key_id, null)
  }

  tags = merge(
    var.tags,
    {
      Name = "pge-epic-${var.app_name}-${var.environment}"
    }
  )
}
