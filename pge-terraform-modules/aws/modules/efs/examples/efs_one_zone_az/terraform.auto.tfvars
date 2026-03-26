account_num = "750713712981"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


kms_name        = "pge_efs_1z_kms_01"
kms_description = "ccoe-pge-efs-1z-kms"

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"

#Efs variables
efs_one_zone_az = "us-west-2a"

#Security-group variables
sg_name        = "efs-sg"
sg_description = "security group for testing efs with pge policy"
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

#tag variables
AppID       = "1001" #Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one environment) 
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader"
Compliance         = ["None"]
Order              = 8115205


optional_tags = {
  Name     = "test"
  pge_team = "ccoe-tf-developers"
}