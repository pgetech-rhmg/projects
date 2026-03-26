aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                          #Order must be between 7 and 9 digits

cluster_id                         = "lanid-snrr-global-primary"
node_type                          = "cache.r6g.large"
redis_engine_version               = "5.0.6"
snapshot_retention                 = 21
final_snapshot                     = null
maintenance_window                 = "sun:05:00-sun:09:00"
snapshot_window                    = "01:00-02:00"
ssm_parameter_name_auth_token      = "/redis/auth_token"
ssm_parameter_name_vpc_id          = "/vpc/2/id"
ssm_parameter_name_private_subnet1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_name_private_subnet2 = "/vpc/2/privatesubnet2/id"
global_suffix                      = "glob1"

#security_group

sg_name        = "lanid-snrr-global-primary"
sg_description = "Security group for example usage with redis"

cidr_ingress_rules = [{
  from             = 2049,
  to               = 2049,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
  ipv6_cidr_blocks = []
  description      = "CCOE Ingress rules"
  prefix_list_ids  = []
  }
]

cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
  ipv6_cidr_blocks = []
  description      = "CCOE egress rules"
  prefix_list_ids  = []
}]

#kms_key
kms_name        = "lanid-snrr-global-primary"
kms_description = "CMK for encrypting redis cache"
kms_role        = "CloudAdmin"
