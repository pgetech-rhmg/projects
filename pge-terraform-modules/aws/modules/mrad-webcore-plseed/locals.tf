locals {
  aws_account_id   = data.aws_caller_identity.current.account_id
  node_env         = var.node_env
  environment_name = local.account_id_to_envname_table[local.aws_account_id]
  suffix           = var.suffix
  swapenv          = local.account_id_to_swapenv[local.aws_account_id]
  repo_branch      = var.repo_branch

  account_id_to_envname_table = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }

  subnet_qualifier = {
    Dev  = "Dev-2",
    QA   = "QA",
    Prod = "Prod"
  }

  account_id_to_swapenv = {
    "990878119577" = "swapdev",
    "471817339124" = "swapqa",
    "712640766496" = "swapprod"
  }

}
