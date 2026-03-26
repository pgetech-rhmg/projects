module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

##### EMR Module #####

locals {
  optional_tags = var.optional_tags
  name = var.name
  cidr_ingress_rules_lambda = []
}

module "emr_instance_fleet" {
  source = "../.."

  name = "${var.name}-instance-fleet"
  release_label_filters = var.release_label_filters
  applications = var.applications
  auto_termination_policy = var.auto_termination_policy
  bootstrap_action = var.bootstrap_action
  configurations_json = var.configurations_json
  master_instance_fleet = var.master_instance_fleet
  core_instance_fleet = var.core_instance_fleet
  task_instance_fleet = var.task_instance_fleet
  ebs_root_volume_size = var.ebs_root_volume_size
  ec2_attributes = {
    instance_profile = var.instance_profile
    subnet_ids = [
        data.aws_ssm_parameter.subnet_id1.value, 
        data.aws_ssm_parameter.subnet_id2.value, 
        data.aws_ssm_parameter.subnet_id3.value
        ]
  }
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  list_steps_states                 = var.list_steps_states
  log_uri                           = "s3://${module.s3_logbucket.id}/emr_logs"
  scale_down_behavior        = var.scale_down_behavior
  step_concurrency_level     = var.step_concurrency_level
  termination_protection     = var.termination_protection
  unhealthy_node_replacement = var.unhealthy_node_replacement
  visible_to_all_users       = var.visible_to_all_users
  service_iam_role_policies  = var.service_iam_role_policies
  iam_instance_profile_policies = var.iam_instance_profile_policies
  tags = merge( module.tags.tags, var.optional_tags)
}


##### Supporting Resources #####

module "s3_vpc_endpoint" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws//modules/vpce_gateway"
  version = "0.1.1"

  service_name    = var.service_name_s3
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  route_table_ids = var.route_table_ids
  tags            = merge(module.tags.tags, var.optional_tags)
}

module "emr_vpc_endpoint" {
  source              = "app.terraform.io/pgetech/vpc-endpoint/aws"
  service_name        = var.service_name_emr
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  private_dns_enabled = var.private_dns_enabled_emr
  security_group_ids  = [module.vpc_endpoints_sg.sg_id]
  tags                = merge(module.tags.tags, local.optional_tags)
}


module "sts_vpc_endpoint" {
  source              = "app.terraform.io/pgetech/vpc-endpoint/aws"
  service_name        = var.service_name_sts
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  private_dns_enabled = var.private_dns_enabled_sts
  security_group_ids  = [module.vpc_endpoints_sg.sg_id]
  tags                = merge(module.tags.tags, local.optional_tags)
}

locals{
    vpc_ep_cidr_ingress_rules = [{
        from             = 443,
        to               = 443,
        protocol         = "tcp",
        cidr_blocks      = [data.aws_subnet.subnet1.cidr_block, 
                            data.aws_subnet.subnet2.cidr_block,
                            data.aws_subnet.subnet3.cidr_block]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        description      = "VPC CIDR HTTPS"
    }
]

}

module "vpc_endpoints_sg" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = "${local.name}-vpc-endpoints"
  description        = "Security group for VPC endpoint access"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = local.vpc_ep_cidr_ingress_rules
  tags               = merge( module.tags.tags, var.optional_tags)
}

module "s3_logbucket" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.3"

  bucket_name = "${local.name}-log-bucket"
  tags        = merge(module.tags.tags, local.optional_tags)
}

