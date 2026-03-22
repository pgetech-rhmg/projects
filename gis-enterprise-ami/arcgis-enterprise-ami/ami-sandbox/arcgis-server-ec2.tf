##############################################################################################
#                         ENT Site ArcGIS Server Machines Creation Module                    #
##############################################################################################

module "arcgis-server-ec2-ent-primary" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.2" #"Check Terraform Registry for latest module version"
  # Primary site node will be only one node and secondary nodes joins with the primary node, 
  # in order to have multiple nodes we need to create separate ec2 modeule for secondary nodes

  name                   = var.entservermachinename
  ami                    = var.server_ami # "Hardcode the AMI ID here to avoid terraform destroy of old machine if ami id changes in SSM"
  instance_type          = var.arcgisserverinstancetype
  availability_zone      = var.availabilityzonea # if you use locals then each.value.az otherwise use var.availabilityzonea #"Change the Availability Zone per requirement"
  instance_profile_role  = var.instanceprofile
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value # if you use locals then each.value.subnet_id otherwise use data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.security_group.sg_id, data.aws_ssm_parameter.windows_sccm_golden.value, data.aws_ssm_parameter.windows_encase_golden.value, data.aws_ssm_parameter.windows_rdp_golden.value, data.aws_ssm_parameter.windows_ad_golden.value, data.aws_ssm_parameter.windows_bmc_scanner_golden.value, data.aws_ssm_parameter.windows_bmc_proxy_golden.value, data.aws_ssm_parameter.windows_scom_golden.value]
  user_data_base64 = base64encode(templatefile("${path.module}/config-script/mount_efs.sh", {
    EFS_ID                = module.arcgis-server-efs-ent.efs_id           # EFS ID for arcgis server content store (required)
    MNT_DIR               = "/mnt/arcgisserver"                # Mount directory for arcgis server config store
  }))
  metadata_http_endpoint = var.metadata_http_endpoint

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = var.throughput
      volume_size = var.arcgisserverprimaryvolume
      kms_key_id  = data.aws_ssm_parameter.electric_kms.value
      tags = {
        Name = var.entservermachinename
      }
    },
  ]

  tags = merge(module.tags.tags, local.optional_tags, { Name = var.entservermachinename, SoftwareComponent = "arcgisserver", ServerRole = "Primary" })

}

module "arcgis-server-efs-ent" {
  source  = "app.terraform.io/pgetech/efs/aws"
  version = "0.1.1" #verify Terraform registry for latest verison of this module"

  kms_key_id      = data.aws_ssm_parameter.electric_kms.value                                               # replace with actual kms key in tfvars file after key is created
  subnet_id       = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value] #"Attach subnets based on AZ you need"
  security_groups = [module.security_group.sg_id]
  tags            = merge(module.tags.tags, local.optional_tags, { Name = var.entserverefsname} )
}
