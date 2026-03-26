#
# Filename    : modules/mrad-sumo/main.tf
# Date        : 10 June 2023
# Author      : MRAD (mrad@pge.com)
# Description : This Terraform module provisions MRAD Sumo integration using Kinesis Firehose for CloudWatch log group subscriptions.
#

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.1.2"
    }
  }
}
