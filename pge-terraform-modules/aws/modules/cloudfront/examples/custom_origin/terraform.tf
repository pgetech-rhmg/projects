terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # The following code is for using cross account assume role
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

#The resource 'aws_kinesis_firehose_delivery_stream' should be created in the 'us-east-1' region since the WAFv2 is created in 'us-east-1'.
#This provider block is used to create the resource in the 'us-east-1' region.
provider "aws" {
  alias  = "east"
  region = "us-east-1"
  # The following code is for using cross account assume role
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}