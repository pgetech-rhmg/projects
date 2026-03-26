run "efs_one_zone_az" {
  command = apply

  module {
    source = "./examples/efs_one_zone_az"
  }
}

variables {
  account_num     = "750713712981"
  aws_role        = "CloudAdmin"
  kms_role        = "CloudAdmin"
  kms_name        = "pge_efs_1z_kms_01"
  kms_description = "ccoe-pge-efs-1z-kms"
  vpc_id_name     = "/vpc/id"
  subnet_id1_name = "/vpc/2/privatesubnet1/id"
  efs_one_zone_az = "us-west-2a"
  sg_name         = "efs-sg"
  sg_description  = "security group for testing efs with pge policy"
  cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.50.195.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.50.108.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    Name     = "test"
    pge_team = "ccoe-tf-developers"
  }
}
