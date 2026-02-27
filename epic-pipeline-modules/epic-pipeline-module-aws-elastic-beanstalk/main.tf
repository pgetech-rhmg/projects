############################################
# Elastic Beanstalk Solution Stack Lookup
# - Use this when your input is a wildcard-like name (preferred in EPIC)
############################################

data "aws_elastic_beanstalk_solution_stack" "type" {
  most_recent = true
  name_regex  = var.solution_stack
}

############################################
# Elastic Beanstalk Application
############################################

resource "aws_elastic_beanstalk_application" "this" {

  name        = "pge-epic-${var.app_name}-${var.environment}-eb-app"
  description = "${var.app_name} - Managed by EPIC"
  tags        = var.tags
}

############################################
# IAM – Service Role (EB Control Plane)
############################################

resource "aws_iam_role" "eb_service_role" {

  name = "pge-epic-${var.app_name}-${var.environment}-eb-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "elasticbeanstalk.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eb_service_managed" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "eb_service_health" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

############################################
# IAM – EC2 Instance Role
############################################

resource "aws_iam_role" "eb_ec2_role" {

  name = "pge-epic-${var.app_name}-${var.environment}-eb-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_worker_tier" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "eb_multicontainer" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

############################################
# IAM – Secrets Manager (Least Privilege)
############################################

resource "aws_iam_role_policy" "secrets_access" {

  count = var.secrets_manager_arn != null && trimspace(var.secrets_manager_arn) != "" ? 1 : 0

  name = "pge-epic-${var.app_name}-${var.environment}-secret-access"
  role = aws_iam_role.eb_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.secrets_manager_arn
    }]
  })
}

############################################
# IAM – Instance Profile
############################################

resource "aws_iam_instance_profile" "eb_instance_profile" {

  name = "pge-epic-${var.app_name}-${var.environment}-eb-instance-profile"
  role = aws_iam_role.eb_ec2_role.name

  tags = var.tags
}

############################################
# Security Groups (Deterministic)
############################################

resource "aws_security_group" "eb_alb" {

  name   = "pge-epic-${var.app_name}-${var.environment}-eb-alb"
  vpc_id = var.network.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.allowed_ingress_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.allowed_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "eb_instances" {

  name   = "pge-epic-${var.app_name}-${var.environment}-eb-ec2"
  vpc_id = var.network.vpc_id

  ingress {
    description     = "Allow traffic from ALB to app port 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eb_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

############################################
# Application Version
############################################

resource "aws_elastic_beanstalk_application_version" "this" {

  name         = "pge-epic-${var.app_name}-${var.environment}-eb-version"
  application  = aws_elastic_beanstalk_application.this.name
  bucket       = var.artifact.bucket
  key          = var.artifact.key
  force_delete = true
  tags         = var.tags
}

############################################
# Elastic Beanstalk Environment
############################################

resource "aws_elastic_beanstalk_environment" "this" {

  name                = "pge-epic-${var.app_name}-${var.environment}-eb-env"
  application         = aws_elastic_beanstalk_application.this.name
  version_label       = aws_elastic_beanstalk_application_version.this.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.type.name

  ##########################################
  # Required Roles
  ##########################################

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  ##########################################
  # Networking (Explicit + Deterministic)
  ##########################################

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.network.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.network.private_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.network.alb_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = local.associate_public_ip ? "true" : "false"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_instances.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_alb.id
  }

  ##########################################
  # Load Balancer
  ##########################################

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = local.alb_scheme
  }

  ##########################################
  # Listener 80 (always)
  ##########################################

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "Protocol"
    value     = "HTTP"
  }

  ##########################################
  # Listener 443 (optional)
  ##########################################

  dynamic "setting" {
    for_each = local.enable_https ? [1] : []

    content {
      namespace = "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = "true"
    }
  }

  dynamic "setting" {
    for_each = local.enable_https ? [1] : []

    content {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
    }
  }

  dynamic "setting" {
    for_each = local.enable_https ? [1] : []

    content {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.security.certificate_arn
    }
  }

  ##########################################
  # Process health check
  ##########################################

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = var.health_check_path
  }

  ##########################################
  # Instance Configuration
  ##########################################

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = local.scaling.min_size
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = local.scaling.max_size
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = local.scaling.instance_type
  }

  ##########################################
  # Logging
  ##########################################

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  ##########################################
  # Environment Variables
  ##########################################

  dynamic "setting" {
    for_each = var.environment_variables

    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  ##########################################
  # Secrets Manager (optional) – EB-native injection
  ##########################################

  dynamic "setting" {
    for_each = var.secrets_manager_arn != null && trimspace(var.secrets_manager_arn) != "" ? [var.secrets_manager_arn] : []

    content {
      namespace = "aws:elasticbeanstalk:application:environmentsecrets"
      name      = "APPSETTINGS"
      value     = setting.value
    }
  }

  tags = var.tags
}
