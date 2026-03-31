data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Base AMI lookup
# data "aws_ami" "base" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = [var.base_ami_name_filter]
#   }

#   filter {
#     name   = "state"
#     values = ["available"]
#   }
# }



# Image Builder Components
resource "aws_imagebuilder_component" "installer" {
  name       = "ami-factory-${var.component_name}-installer-${var.environment}"
  platform   = "Linux"
  version    = var.component_version
  data       = var.installer_yaml
  kms_key_id = var.kms_key_arn

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })

}

resource "aws_imagebuilder_component" "test" {
  name       = "ami-factory-${var.component_name}-test-${var.environment}"
  platform   = "Linux"
  version    = var.component_version
  data       = var.test_yaml
  kms_key_id = var.kms_key_arn

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })
}

# Image Recipe
resource "aws_imagebuilder_image_recipe" "this" {
  name         = "ami-factory-${var.component_name}-${var.environment}"
  parent_image = var.source_ami_id
  version      = var.recipe_version

  lifecycle {
    create_before_destroy = true
  }

  block_device_mapping {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_size           = var.ebs_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_arn
    }
  }

  component {
    component_arn = aws_imagebuilder_component.installer.arn
  }

  component {
    component_arn = aws_imagebuilder_component.test.arn
  }

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })
}

# Infrastructure Configuration
resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                          = "ami-factory-${var.component_name}-${var.environment}"
  instance_profile_name         = var.instance_profile_name
  instance_types                = var.instance_types
  security_group_ids            = [var.security_group_id]
  subnet_id                     = var.subnet_id
  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = var.log_bucket
      s3_key_prefix  = "image-builder/${var.component_name}"
    }
  }

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })
}

# Distribution Configuration for cross-account sharing
resource "aws_imagebuilder_distribution_configuration" "this" {
  name = "ami-factory-${var.component_name}-${var.environment}"

  distribution {
    region = data.aws_region.current.region

    ami_distribution_configuration {
      name = "ami-factory-${var.component_name}-${var.environment}-{{ imagebuilder:buildDate }}"

      ami_tags = merge(var.tags, {
        Component   = var.component_name
        Environment = var.environment
        BuildDate   = "{{ imagebuilder:buildDate }}"
        BaseAMI     = var.source_ami_id
      })

      kms_key_id = var.kms_key_arn

      launch_permission {
        user_ids = var.share_account_ids
      }
    }
  }

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })
}

# Image Pipeline
resource "aws_imagebuilder_image_pipeline" "this" {
  name                             = "ami-factory-${var.component_name}-${var.environment}"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  status                           = "ENABLED"

  tags = merge(var.tags, {
    Component = var.component_name
    Environment = var.environment
  })
}
