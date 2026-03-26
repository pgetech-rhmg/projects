run "ebs_with_multi_attach" {
  module {
    source = "./examples/ebs_with_multi_attach"
  }
}

variables {
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  kms_role                 = "CloudAdmin"
  account_num              = "750713712981"
  AppID                    = "443"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["SOX", "HIPAA"]
  Optional_tags            = { pge_team = "ccoe-tf-developers" }
  vpc_id_name              = "/vpc/id"
  subnet_id1_name          = "/vpc/2/privatesubnet1/id"
  golden_ami_name          = "/ami/linux/golden"
  ebs_availability_zone    = "us-west-2a"
  ebs_multi_attach_enabled = true
  ebs_size                 = 8
  ebs_type                 = "io1"
  ebs_iops                 = 100
  ebs_device_name          = "/dev/sdh"
  kms_name                 = "test-ebs"
  kms_description          = "kms for ebs"
  ec2_01_name              = "ec2test"
  ec2_02_name              = "testec2"
  ec2_az                   = "us-west-2a"
  ec2_instance_type        = "c5.large"
  sg_name                  = "ebs-sg"
  sg_description           = "Security group for example usage with EBS"
  Order                    = 8115205
  cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.108.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}
