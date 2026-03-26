run "pge_linux" {
  command = apply

  module {
    source = "./examples/pge_linux"
  }
}

variables {
  account_num            = "750713712981"
  aws_region             = "us-west-2"
  aws_role               = "CloudAdmin"
  kms_role               = "CloudAdmin"
  kms_name               = "pge_linux_kms_01"
  kms_description        = "ccoe-pge-linux-kms"
  AppID                  = "1001"
  Environment            = "Dev"
  DataClassification     = "Internal"
  CRIS                   = "Medium"
  Notify                 = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                  = ["abc1", "def2", "ghi3"]
  Compliance             = ["None"]
  Order                  = 8115205
  Name                   = "test-ccoe-ec2-linux-a8tq"
  InstanceType           = "t2.micro"
  AvailabilityZone       = "us-west-2a"
  metadata_http_endpoint = "enabled"
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rule - 1"
    }, {
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["172.16.0.0/12"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rule - 2"
    }, {
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["192.168.0.0/16"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 ingress rule- 3"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ec2 egress rules"
  }]
}
