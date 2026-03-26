provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${local.account_num}:role/${local.aws_role}"
    session_name = "${local.user}-${local.aws_role}"
  }
}

provider "aws" {
  region = var.aws_region_replica
  alias  = "replica"
  assume_role {
    role_arn     = "arn:aws:iam::${local.account_num}:role/${var.aws_role}"
    session_name = "${local.user}-${local.aws_role}"
  }
}