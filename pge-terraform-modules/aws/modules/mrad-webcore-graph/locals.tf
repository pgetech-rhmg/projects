locals {
  account_num                  = data.aws_caller_identity.current.account_id
  environment_name             = local.account_id_to_envname_table[local.account_num]
  neptune_backup_retention     = local.account_name_to_backup_retention_table[local.environment_name]
  neptune_instance_count       = local.account_name_to_neptune_instances_table[local.environment_name]
  neptune_db_instance_class    = local.account_name_to_neptune_instance_size[local.environment_name]
  healthcheck_url              = local.account_name_to_healthcheck_url[local.environment_name]
  principal_orgid              = "o-7vgpdbu22o"
  graph_repo_commit            = data.github_branch.graph_current_branch.sha
  ecr_image_retention          = local.account_num_to_ecr_image_retention[local.account_num]

  account_id_to_envname_table = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }

  account_name_to_backup_retention_table = {
    Dev  = 2,
    QA   = 2,
    Prod = 24
  }

  account_name_to_neptune_instances_table = {
    Dev  = 3,
    QA   = 3,
    Prod = 3
  }

  account_name_to_neptune_instance_size = {
    Dev  = "db.r6g.large",
    QA   = "db.r6g.xlarge",
    Prod = "db.r6g.4xlarge"
  }

  account_name_to_healthcheck_url = {
    "Dev"  = "http://localhost:8080",
    "QA"   = "http://localhost:8080",
    "Prod" = "http://localhost:8080"
  }

  subnet_qualifier = {
    Dev  = "Dev-2",
    QA   = "QA",
    Prod = "Prod"
  }

  account_num_to_ecr_image_retention = {
    "990878119577" = 3
    "471817339124" = 3
    "712640766496" = 6
  }

}
