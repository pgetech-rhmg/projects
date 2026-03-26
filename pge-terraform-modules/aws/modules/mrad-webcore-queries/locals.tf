locals {
  # constants
  short_name      = lower(var.short_name)
  principal_orgid = "o-7vgpdbu22o"
  envname        = local.account_num_to_environment[local.account_num]
  # environment_name is equivalent to aws_account
  account_num                  = data.aws_caller_identity.current.account_id
  subdomain                    = local.account_num_to_subdomain[local.account_num]
  task_cpu                     = local.account_num_to_cpu[local.account_num]
  task_memory                  = local.account_num_to_memory[local.account_num]
  task_count                   = local.account_num_to_task_count[local.account_num]
  lb_subject_alternative_names = local.account_num_to_lb_subject_alternative_names[local.account_num]
  lb_fqdn                      = local.account_num_to_lb_fqdn[local.account_num]
  healthcheck_url              = local.account_name_to_healthcheck_url[local.envname]
  queries_repo_commit          = data.github_branch.queries_current_branch.sha
  ecr_image_retention          = local.account_num_to_ecr_image_retention[local.account_num]
  prefix                       = lower(var.prefix)
  suffix                       = lower(var.suffix)
  git_branch                   = var.git_branch
  queries_resource_name        = "${local.prefix}-${local.short_name}-${local.suffix}"

  account_num_to_environment = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }
  account_name_to_healthcheck_url = {
    "Dev"  = "https://nginx-ecs-fargate.dev.dc.pge.com",
    "QA"   = "https://nginx-ecs-fargate.qa.dc.pge.com",
    "Prod" = "https://nginx-ecs-fargate.prod.dc.pge.com"
  }

  subnet_qualifier = {
    Dev  = "Dev-2",
    QA   = "QA",
    Prod = "Prod"
  }

  account_num_to_nodeenv = {
    "990878119577" = "dev",
    "471817339124" = "qa",
    "712640766496" = "production"
  }

  account_num_to_cpu = {
    "990878119577" = "1024",
    "471817339124" = "1024",
    "712640766496" = "1024"
  }

  account_num_to_memory = {
    "990878119577" = "2048",
    "471817339124" = "2048",
    "712640766496" = "2048"
  }

  # set to 0 for now, will be updated later by pipeline
  account_num_to_task_count = {
    "990878119577" = "0",
    "471817339124" = "0",
    "712640766496" = "0"
  }

  account_num_to_lb_fqdn = {
    "990878119577" = "${local.queries_resource_name}.nonprod.pge.com",
    "471817339124" = "${local.queries_resource_name}.dc.pge.com",
    "712640766496" = "${local.queries_resource_name}.dc.pge.com"
  }

  # currently only production has an alternative name
  account_num_to_lb_subject_alternative_names = {
    "990878119577" = [],
    "471817339124" = [],
    "712640766496" = ["engage-queries-prod.dc.pge.com"]
  }

  # account number to DNS subdomain
  account_num_to_subdomain = {
    "990878119577" = "nonprod.pge.com"
    "471817339124" = "dc.pge.com"
    "712640766496" = "dc.pge.com"
  }

  account_num_to_ecr_image_retention = {
    "990878119577" = "3"
    "471817339124" = "3"
    "712640766496" = "6"
  }
}
