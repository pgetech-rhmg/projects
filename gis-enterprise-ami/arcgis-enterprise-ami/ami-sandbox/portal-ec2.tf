##############################################################################################
#                           ArcGIS Portal Machines Creation Module                           #
##############################################################################################

resource "random_password" "portal_admin_password" {
  # ESRI requirement : The password can only have the numbers 0-9, the ASCII letters a-z, A-Z and the dot character (.).
  length  = 16
  special = false
}

module "portal-ec2-primary" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.2" #"Check Terraform Registry for latest module version"
  # Portal site will have only one node in active-passive configuration 
  # and can only have one secondary node joining the primary node,

  name                   = var.portalmachinename
  ami                    = var.portal_ami # "Hardcode the AMI ID here to avoid terraform destroy of old machine if ami id changes in SSM"
  instance_type          = var.portalinstancetype
  availability_zone      = local.AvailabilityZoneA #"Change the Availability Zone per requirement"
  instance_profile_role  = var.instanceprofile
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value #"Change the Subnet id according to Availability Zone information"
  vpc_security_group_ids = [module.security_group.sg_id, data.aws_ssm_parameter.windows_sccm_golden.value, data.aws_ssm_parameter.windows_encase_golden.value, data.aws_ssm_parameter.windows_rdp_golden.value, data.aws_ssm_parameter.windows_ad_golden.value, data.aws_ssm_parameter.windows_bmc_scanner_golden.value, data.aws_ssm_parameter.windows_bmc_proxy_golden.value, data.aws_ssm_parameter.windows_scom_golden.value]
  user_data_base64       = base64encode(local.user_data)

  metadata_http_endpoint = var.metadata_http_endpoint

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = var.throughput
      volume_size = var.portalprimaryvolume
      kms_key_id  = data.aws_ssm_parameter.electric_kms.value
      tags = {
        Name = var.portalmachinename
      }
    },
  ]

  tags = merge(module.tags.tags, local.optional_tags, {  Name = var.portalmachinename,SoftwareComponent = "arcgisportal", PortalRole = "Primary" })

}

###############################################
# Create S3 bucket with user defined policy   #
###############################################
module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.3"                              #verify Terraform registry for latest verison of this module"
  bucket_name = var.portal_bucket_name               #either pass the bucket name from env specific tfvars file or add suffix after var.bucket_name EX: "${var.bucket_name}_random string"
  kms_key_arn = data.aws_ssm_parameter.electric_kms.value # replace with actual kms key in tfvars file after key is created
  versioning  = var.versioning
  policy      = templatefile("${path.module}/s3_bucket_policy.json", { aws_role = var.aws_role, account_num = var.account_num, bucket_name = var.portal_bucket_name }) # // You can use your custom policy based on need //
  tags        = merge(module.tags.tags)

}

###############################################
#                   Create EFS                #
###############################################

module "portal-efs" {
  source  = "app.terraform.io/pgetech/efs/aws"
  version = "0.1.1" #verify Terraform registry for latest verison of this module"

  kms_key_id      = data.aws_ssm_parameter.electric_kms.value                                               # replace with actual kms key in tfvars file after key is created
  subnet_id       = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value] #"Attach subnets based on AZ you need"
  security_groups = [module.security_group.sg_id]
  tags            = merge(module.tags.tags, local.optional_tags, { Name = var.portalefsname} )
}

#################################################
# Secret key
#################################################

module "secretsmanager" {
  source  = "app.terraform.io/pgetech/secretsmanager/aws"
  version = "0.1.3"

  secretsmanager_name        = var.portal_secretsmanager_name
  secretsmanager_description = var.portal_secretsmanager_description
  kms_key_id                 = data.aws_ssm_parameter.electric_kms.value # replace with module.kms_key.key_arn, after key creation
  recovery_window_in_days    = var.recovery_window_in_days          #this is set to 0 days for testing. for safety purpose the default is set to 30 days
  secret_string              = random_password.portal_admin_password.result
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}