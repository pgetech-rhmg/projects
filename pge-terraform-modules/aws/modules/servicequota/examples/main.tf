locals {
  regions = [
    "us-west-2",
  ]
}

module "dashboard" {
  source  = "../modules/dashboard"
  regions = local.regions
  providers = {
    aws = aws.us-east-1
  }

}


module "trusted_advisor_alarms" {
  source  = "../modules/trusted_advisor_alarms"
  regions = local.regions
  providers = {
    aws = aws.us-east-1
  }
}

module "usage_alarms_us_east_1" {
  source = "../modules/usage_alarms"
  providers = {
    aws = aws.us-east-1
  }
}

module "usage_alarms_us_west_2" {
  source = "../modules/usage_alarms"
  providers = {
    aws = aws.us-west-2
  }
}