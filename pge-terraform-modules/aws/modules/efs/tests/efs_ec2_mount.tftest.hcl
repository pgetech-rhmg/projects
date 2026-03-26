run "efs_ec2_mount" {
  command = apply

  module {
    source = "./examples/efs_ec2_mount"
  }
}

variables {
  account_num     = "750713712981"
  aws_role        = "CloudAdmin"
  kms_role        = "CloudAdmin"
  kms_name        = "pge_efs_ec2_kms_01"
  kms_description = "ccoe-pge-efs-ec2-kms"
  vpc_id_name     = "/vpc/id"
  subnet_id1_name = "/vpc/2/privatesubnet1/id"
  subnet_id2_name = "/vpc/privatesubnet3/id"
  golden_ami_name = "/ami/linux/golden"
  sg_name         = "efs-sg"
  sg_description  = "Security group for example usage with EFS instance"
  cidr_ingress_rules = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 2049,
      to               = 2049,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
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
  ec2_name                      = "ec2-efs"
  ec2_instance_type             = "t2.micro"
  ec2_az                        = "us-west-2a"
  root_block_device_volume_type = "gp3"
  root_block_device_throughput  = 200
  root_block_device_volume_size = 50
}
