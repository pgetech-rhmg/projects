/*
* # ASG with launch template, security group, IAM role, and ALB for sonarqube
*/
#
# Filename    : main.tf
# Date        : 22 May 2024
# Author      : ccoe-tf-developers
# Description : ASG with launch template, ALB, and ACM, and R53 for a web app deployment


locals {
  namespace                 = "ccoe-tf-developers"
  user_data                 = var.user_data != null ? base64encode(var.user_data) : null
  module_tags               = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  custom_domain_name        = var.custom_domain_name
  base_domain_name          = regex("(.*).(alerts.pge.com|ccare.pge.com|cloudapi.pge.com|dc.pge.com|dcs.pge.com|digitalcatalyst.pge.com|io.pge.com|ss-dev.pge.com|ss.pge.com|pgepspsmap.com|pgepspsmaps.com|pgecloud.net|nonprod.pge.com|np-dev.pge.com|nonprod.pge.com|np-dev-api.pge.com|np-dev.pge.com)", var.custom_domain_name)[1]
  subject_alternative_names = distinct(var.subject_alternative_names)
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

module "asg_with_launch_template" {
  source  = "app.terraform.io/pgetech/asg/aws"
  version = "0.1.1"

  tags = local.module_tags

  launch_template_name                 = var.launch_template_name
  autoscaling_policy_name              = var.autoscaling_policy_name
  asg_vpc_zone_identifier              = var.asg_vpc_zone_identifier
  security_groups                      = var.ec2_security_groups
  instance_type                        = var.instance_type
  image_id                             = var.image_id
  scaling_adjustment                   = var.scaling_adjustment
  adjustment_type                      = var.adjustment_type
  policy_type                          = var.policy_type
  asg_name                             = var.asg_name
  asg_max_size                         = var.asg_max_size
  asg_min_size                         = var.asg_min_size
  asg_desired_capacity                 = var.asg_desired_capacity
  asg_force_delete                     = var.asg_force_delete
  asg_health_check_grace_period        = var.asg_health_check_grace_period
  asg_health_check_type                = var.asg_health_check_type
  cooldown                             = var.cooldown
  create_launch_template               = var.create_launch_template
  user_data                            = local.user_data
  instance_name                        = var.instance_name
  block_device_mappings                = var.block_device_mappings
  asg_name_prefix                      = var.asg_name_prefix
  asg_capacity_rebalance               = var.asg_capacity_rebalance
  asg_default_cooldown                 = var.asg_default_cooldown
  launch_template_version              = var.launch_template_version
  iam_instance_profile                 = var.iam_instance_profile
  asg_target_group_arns                = values(module.alb.target_group_arn)
  asg_termination_policies             = var.asg_termination_policies
  asg_suspended_processes              = var.asg_suspended_processes
  asg_placement_group                  = var.asg_placement_group
  asg_enabled_metrics                  = var.asg_enabled_metrics
  asg_wait_for_capacity_timeout        = var.asg_wait_for_capacity_timeout
  asg_min_elb_capacity                 = var.asg_min_elb_capacity
  asg_wait_for_elb_capacity            = var.asg_wait_for_elb_capacity
  asg_protect_from_scale_in            = var.asg_protect_from_scale_in
  asg_service_linked_role_arn          = var.asg_service_linked_role_arn
  asg_max_instance_lifetime            = var.asg_max_instance_lifetime
  warm_pool                            = var.warm_pool
  checkpoint_delay                     = var.checkpoint_delay
  checkpoint_percentages               = var.checkpoint_percentages
  instance_warmup                      = var.instance_warmup
  min_healthy_percentage               = var.min_healthy_percentage
  strategy                             = var.strategy
  initial_lifecycle_hooks              = var.initial_lifecycle_hooks
  triggers                             = var.triggers
  asg_load_balancers                   = var.asg_load_balancers
  estimated_instance_warmup            = var.estimated_instance_warmup
  capacity_reservation_specification   = var.capacity_reservation_specification
  disable_api_stop                     = var.disable_api_stop
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  elastic_gpu_specifications           = var.elastic_gpu_specifications
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  kernel_id                            = var.kernel_id
  ram_disk_id                          = var.ram_disk_id
  network_interfaces                   = var.network_interfaces
  cpu_options                          = var.cpu_options
  instance_market_options              = var.instance_market_options
  tag_specifications                   = var.tag_specifications
  launch_template                      = var.launch_template
  use_mixed_instances_policy           = var.use_mixed_instances_policy
  placement                            = var.placement
  credit_specification                 = var.credit_specification
  metadata_options                     = var.metadata_options
}

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.1"

  tags = local.module_tags

  vpc_id                     = var.vpc_id
  alb_name                   = var.alb_name
  subnets                    = var.alb_subnets
  security_groups            = var.alb_security_groups
  bucket_name                = var.alb_log_bucket_name
  lb_target_group            = var.lb_target_group
  lb_listener_http           = var.lb_listener_http
  lb_listener_https          = var.lb_listener_https
  lb_listener_rule_http      = var.lb_listener_rule_http
  lb_listener_rule_https     = var.lb_listener_rule_https
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_waf_fail_open       = var.enable_waf_fail_open
  enable_http2               = var.enable_http2
}

module "acm_public_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"

  tags = local.module_tags

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_subject_alternative_names = local.subject_alternative_names
  acm_domain_name               = var.custom_domain_name
  allow_overwrite               = var.allow_overwrite

}

module "r53" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  zone_id = data.aws_route53_zone.private_zone.zone_id

  providers = {
    aws = aws.r53
  }

  records = [
    {
      name    = local.custom_domain_name
      type    = "CNAME"
      ttl     = "300"
      records = [module.alb.lb_dns_name]
    }
  ]
}
