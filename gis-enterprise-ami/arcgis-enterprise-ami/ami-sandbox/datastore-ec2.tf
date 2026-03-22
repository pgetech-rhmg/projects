##############################################################################################
#                           ArcGIS DataStore Machines Creation Module                        #
##############################################################################################

module "datastore-ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.2" #"Check Terraform Registry for latest module version"
  #count   = var.DataStoreMachineCount

  name                   = var.datastoremachinename
  ami                    = var.datastore_ami # "Hardcode the AMI ID here to avoid terraform destroy of old machine if ami id changes in SSM"
  instance_type          = var.datastoreinstancetype
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
      volume_size = var.datastoreprimaryvolume
      kms_key_id  = data.aws_ssm_parameter.electric_kms.value
      tags = {
        Name = var.datastoremachinename
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      encrypted   = true
      volume_type = "gp3"
      volume_size = 500
      throughput  = var.throughput
      kms_key_id  = data.aws_ssm_parameter.electric_kms.value
      tags = {
        Name = var.datastoreebsname
      }
    },
  ]

  tags = merge(module.tags.tags, local.optional_tags, { Name = var.datastoremachinename, SoftwareComponent = "arcgisdatastore", DatastoreRole = "Primary" })

}
