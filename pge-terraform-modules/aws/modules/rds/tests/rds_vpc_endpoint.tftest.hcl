run "rds_vpc_endpoint" {
  command = apply

  module {
    source = "./examples/rds_vpc_endpoint"
  }
}

variables {
  aws_region  = "us-west-2"
  account_num = "750713712981"
  aws_role    = "CloudAdmin"
  tags = {
    Owner              = "abc1_def2_ghi3"
    AppID              = "APP-1001"
    Environment        = "Dev"
    DataClassification = "Internal"
    Compliance         = "None"
    CRIS               = "High"
    Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
    Order              = 8115205
    CreatedBy          = "rb1c"
  }
  service_name = "com.amazonaws.us-west-2.rds"
  optional_tags = {
    CreatedBy = "rb1c"
    pge_team  = "ccoe-tf-developers"
  }
  sg_name = "rds-vpc-end-sg"
  cidr_ingress_rules = [
    {
      from             = 1521,
      to               = 1521,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.112.128/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS Ingress rule"
    },
    {
      from             = 2484,
      to               = 2484,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.112.128/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS Ingress rule"
    }
  ]
}
