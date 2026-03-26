provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
    session_name = "${var.user}-${var.aws_role}"
  }
}

provider "aws" {
  region = var.aws_region_replica
  alias  = "replica"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
    session_name = "${var.user}-${var.aws_role}"
  }
}