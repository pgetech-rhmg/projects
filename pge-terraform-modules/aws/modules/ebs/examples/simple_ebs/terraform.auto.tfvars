aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"
account_num = "750713712981"

#Tag variables
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Optional_tags      = { pge_team = "ccoe-tf-developers" }

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
golden_ami_name = "/ami/linux/golden"

#Ebs variables
ebs_availability_zone = "us-west-2a"
ebs_size              = 8
ebs_type              = "gp2"
ebs_device_name       = "/dev/sdh"

#Kms variables
kms_name        = "test-ebs-aicg"
kms_description = "kms for ebs"

#Ec2 variables
ec2_name          = "ec2test"
ec2_instance_type = "t2.micro"
ec2_az            = "us-west-2a"

#Security group variables
sg_name        = "ebs-sg"
sg_description = "Security group for example usage with EBS"


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