/*
* # ArcGIS Web Adaptor Image Builder
*/
################################################################################
# Resources
################################################################################
# Security Group for Image Builder Instances (if not provided)
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${var.name}-sg"
  description = "Security group for ArcGIS Web Adaptor Image Builder instances"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags              = module.tags.tags
}

# CloudWatch log group
# module "cloudwatch" {
#   source  = "app.terraform.io/pgetech/cloudwatch/aws"
#   version = "0.1.3"
#   name = "/aws/imagebuilder/${var.name}"
#   retention_in_days = 30
#   kms_key_id  = null # replace with module.kms_key.key_arn, after key creation
#   tags = module.tags.tags
# }

# Web Adaptor Image Recipes for Linux (RHEL)
resource "aws_imagebuilder_image_recipe" "webadaptor_linux" {
  name         = var.name
  parent_image = data.aws_ssm_parameter.rhellinux_golden_ami.value 
  version      = var.recipe_version
  description  = "ArcGIS Web Adaptor ${var.arcgis_version} for RHEL Linux"
  working_directory = "/tmp"
  block_device_mapping {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_size          = var.recipe_volume_size
      volume_type          = "gp3"
      throughput           = var.block_device_throughput
    }
  }

  component {
    component_arn = aws_imagebuilder_component.webadaptor_linux_install.arn
  }

  # # AWS managed components
  # component {
  #   component_arn = "arn:aws:imagebuilder:us-west-2:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1"
  # }

  lifecycle {
    create_before_destroy = true
  }

  tags = module.tags.tags
}

# Generate random password for SSL certificate
resource "random_password" "ssl_cert_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# EC2 Image Builder Component for Linux (RHEL) ArcGIS Web Adaptor Installation
resource "aws_imagebuilder_component" "webadaptor_linux_install" {
  name     = "arcgis-webadaptor-linux-install"
  platform = "Linux"
  version  = var.build_version

  data = templatefile("${path.module}/components/install-arcgis-webadaptor-linux.yml", {
    deployment_bucket           = var.deployment_bucket
    workflow_installer_key_name = var.workflow_installer_key_name
    java_openjdk_17_key_name    = var.java_openjdk_17_key_name
    webadaptor_installer_key_name = var.webadaptor_installer_key_name
    tomcat_key_name              = var.tomcat_key_name
    arcgis_version               = var.arcgis_version
    java_version                = var.java_version
    tomcat_version              = var.tomcat_version
    ssl_cert_password            = resource.random_password.ssl_cert_password.result
  })

  supported_os_versions = var.supported_os_versions_linux

  lifecycle {
    create_before_destroy = true
  }


  tags = module.tags.tags
}


# Infrastructure Configuration
resource "aws_imagebuilder_infrastructure_configuration" "main" {
  name                          = local.infrastructure_config_name
  description                   = "Infrastructure configuration for ArcGIS Web Adaptor AMI builds"
  instance_profile_name         = aws_iam_instance_profile.imagebuilder_instance_profile.name
  instance_types                = var.ec2_imagebuilder_instance_type
  key_pair                      = null
  security_group_ids            = [module.security-group.sg_id]
  subnet_id                     = data.aws_ssm_parameter.subnet_id1.value
  terminate_instance_on_failure = false

  instance_metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  logging {
    s3_logs {
      s3_bucket_name = module.ec2_image_builder_s3_bucket.id
      s3_key_prefix  = "logs"
    }
  }
  resource_tags = module.tags.tags
  tags         = module.tags.tags
}

# Distribution Configuration
resource "aws_imagebuilder_distribution_configuration" "main" {
  name        = local.distribution_config_name
  description = "Distribution configuration for ArcGIS Web Adaptor AMIs"

  distribution {
    ami_distribution_configuration {
      name        = "${var.ami_name}-{{imagebuilder:buildDate}}"
      description = "ArcGIS Web Adaptor ${var.arcgis_version} Linux AMI"
      ami_tags    = module.tags.tags
      target_account_ids = local.has_shared_accounts ? var.share_with_accounts : []
    }

    region = var.aws_region
  }

  dynamic "distribution" {
    for_each = var.distribution_regions
    content {
      ami_distribution_configuration {
        name        = "${var.ami_name}-{{imagebuilder:buildDate}}"
        description = "ArcGIS Workflow Manager ${var.arcgis_version} Linux AMI"
        ami_tags    = module.tags.tags
        target_account_ids = local.has_shared_accounts ? var.share_with_accounts : []
      }

      region = distribution.value
    }
  }

  tags = module.tags.tags
}

# Image Pipelines
resource "aws_imagebuilder_image_pipeline" "webadaptor_linux" {
  name                             = local.linux_pipeline_name
  description                      = "ArcGIS Web Adaptor Linux AMI Pipeline"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.webadaptor_linux.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.main.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  status                          = "ENABLED"
  enhanced_image_metadata_enabled = var.enable_enhanced_metadata

  image_tests_configuration {
    image_tests_enabled = var.enable_instance_tests
    timeout_minutes     = var.test_timeout_minutes
  }

  dynamic "schedule" {
    for_each = local.has_build_schedule ? [1] : []
    content {
      schedule_expression                = var.build_schedule
      pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    }
  }

  tags = module.tags.tags
}


module "ec2_image_builder_s3_bucket" {
  source                  = "app.terraform.io/pgetech/s3/aws"
  version                 = "0.1.3"
  bucket_name             = lower("${var.bucket_name}-${var.Environment}")
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  tags                    = module.tags.tags
  force_destroy           = var.force_destroy_s3_bucket
  policy                  = templatefile("${path.module}/${var.log_policy}", { bucket = lower("${var.bucket_name}-${var.Environment}") })
  kms_key_arn             = data.aws_ssm_parameter.gas_kms.value
}