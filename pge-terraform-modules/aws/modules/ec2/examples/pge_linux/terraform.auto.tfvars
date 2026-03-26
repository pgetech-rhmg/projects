account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"


kms_name        = "pge_linux_kms_01"
kms_description = "ccoe-pge-linux-kms"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Medium"                                         #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits

Name             = "test-ccoe-ec2-linux"
InstanceType     = "t2.micro"
AvailabilityZone = "us-west-2a"
### use instance_profile_role if you want to use an custom instance profile role
# instance_profile_role = "instance_role_ccoe-test-example_dRQ"
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