

/*
* # AWS EC2 Image Builder module Example for Amazon Linux 2023
*/

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Order              = local.Order
  Compliance         = local.Compliance
}

module "ec2-image-builder" {
  source                           = "../../"
  name                             = var.name
  vpc_id                           = var.vpc_id
  subnet_id                        = var.private_subnet
  parent_image_ssm_path            = var.parent_image_ssm_path
  s3_bucket_name                   = module.ec2_image_builder_s3_bucket.id
  recipe_version                   = var.recipe_version
  ec2_imagebuilder_instance_types  = var.ec2_imagebuilder_instance_type
  delete_on_termination_img_recipe = var.delete_on_termination_img_recipe
  uninstall_after_build            = var.uninstall_after_build
  recipe_description               = var.recipe_description
  block_device_iops                = var.block_device_iops
  execution_role                   = var.execution_role
  ami_name                         = var.ami_name
  launch_permission_user_ids       = var.launch_permission_user_ids
  receipients                      = var.receipients
  sender                           = var.sender
  target_accounts_table            = var.target_accounts_table
  component_version                = "1.0.0"
  component_name                   = "test1"
  component_platform               = "Linux"
  component_data = {
    #component_cloudwatch_agent = "${path.module}/component_cloudwatch_agent.yml" #File Path
    component_ssm_agent = "${path.module}/component_ssm_agent.yml" #Data URI
  }
  aws_owned_component_arn = ["arn:aws:imagebuilder:us-west-2:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1"]

  tags                          = merge(module.tags.tags, local.optional_tags)
  image_tests_enabled           = var.image_tests_enabled
  pipeline_status               = var.pipeline_status
  terminate_instance_on_failure = true
  vpc_cidr                      = var.vpc_cidr
  notification_email            = var.notification_email
  account_num                   = var.account_num
  ssm_document_name             = var.ssm_document_name
  distribution_regions          = var.distribution_regions
  aws_region                    = var.aws_region
  ami_parameter_store_status    = var.ami_parameter_store_status
}

module "ec2_image_builder_s3_bucket" {
  source                  = "app.terraform.io/pgetech/s3/aws"
  version                 = "0.1.0"
  bucket_name             = var.bucket_name
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  tags                    = merge(module.tags.tags, local.optional_tags)
  force_destroy           = var.force_destroy_s3_bucket
  policy                  = templatefile("${path.module}/${var.log_policy}", { bucket = var.bucket_name })
  kms_key_arn             = null # replace with module.kms_key.key_arn, after key creation
}
