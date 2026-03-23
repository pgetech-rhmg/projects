###############################################################################
# EC2 Image Builder Pipeline
#
# Creates a complete Image Builder pipeline for a single component:
#   - Installer component (YAML)
#   - Test component (YAML)
#   - Image recipe (base AMI + components + encrypted EBS)
#   - Infrastructure configuration (instance profile, networking, logging)
#   - Distribution configuration (AMI naming, tags, cross-account sharing)
#   - Image pipeline (ties everything together)
###############################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  prefix = "ami-factory-${var.component_name}-${var.environment}"
}


###############################################################################
# Image Builder Components
###############################################################################

resource "aws_imagebuilder_component" "installer" {
  name        = "${local.prefix}-installer"
  platform    = "Linux"
  version     = var.component_version
  description = "Install ${var.component_name} for ArcGIS Enterprise"
  tags        = var.tags

  data = yamlencode({
    schemaVersion = 1.0
    phases = [{
      name = "build"
      steps = [{
        name   = "InstallComponent"
        action = "ExecuteBash"
        inputs = {
          commands = [
            "echo 'Installing ${var.component_name} from s3://${var.esri_assets_bucket}'",
            "aws s3 cp s3://${var.esri_assets_bucket}/${var.component_name}/ /tmp/${var.component_name}/ --recursive",
            "chmod +x /tmp/${var.component_name}/install.sh",
            "/tmp/${var.component_name}/install.sh"
          ]
        }
      }]
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_imagebuilder_component" "test" {
  name        = "${local.prefix}-test"
  platform    = "Linux"
  version     = var.component_version
  description = "Validate ${var.component_name} installation"
  tags        = var.tags

  data = yamlencode({
    schemaVersion = 1.0
    phases = [{
      name = "test"
      steps = [{
        name   = "ValidateComponent"
        action = "ExecuteBash"
        inputs = {
          commands = [
            "echo 'Validating ${var.component_name} installation'",
            "aws s3 cp s3://${var.esri_assets_bucket}/${var.component_name}/validate.sh /tmp/validate.sh || true",
            "if [ -f /tmp/validate.sh ]; then chmod +x /tmp/validate.sh && /tmp/validate.sh; fi"
          ]
        }
      }]
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}


###############################################################################
# Image Recipe
###############################################################################

resource "aws_imagebuilder_image_recipe" "this" {
  name         = local.prefix
  parent_image = var.source_ami_id
  version      = var.recipe_version
  tags         = var.tags

  component {
    component_arn = aws_imagebuilder_component.installer.arn
  }

  component {
    component_arn = aws_imagebuilder_component.test.arn
  }

  block_device_mapping {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      volume_size           = tonumber(var.ebs_volume_size)
      volume_type           = "gp3"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


###############################################################################
# Infrastructure Configuration
###############################################################################

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                  = local.prefix
  instance_profile_name = var.instance_profile_name
  instance_types        = var.instance_types
  security_group_ids    = [var.security_group_id]
  subnet_id             = var.subnet_id
  tags                  = var.tags

  logging {
    s3_logs {
      s3_bucket_name = var.log_bucket
      s3_key_prefix  = "image-builder/${var.component_name}"
    }
  }
}


###############################################################################
# Distribution Configuration
###############################################################################

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = local.prefix
  tags = var.tags

  distribution {
    region = data.aws_region.current.name

    ami_distribution_configuration {
      name        = "${local.prefix}-{{imagebuilder:buildDate}}"
      description = "AMI for ${var.component_name} (${var.environment})"

      ami_tags = merge(var.tags, {
        Component   = var.component_name
        Environment = var.environment
        BuildDate   = "{{imagebuilder:buildDate}}"
        BaseAMI     = var.source_ami_id
      })

      dynamic "launch_permission" {
        for_each = length(var.share_account_ids) > 0 ? [1] : []
        content {
          user_ids = var.share_account_ids
        }
      }

      kms_key_id = var.kms_key_arn
    }
  }
}


###############################################################################
# Image Pipeline
###############################################################################

resource "aws_imagebuilder_image_pipeline" "this" {
  name                             = local.prefix
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  status                           = "ENABLED"
  tags                             = var.tags
}
