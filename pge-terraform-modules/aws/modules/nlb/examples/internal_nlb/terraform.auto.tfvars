account_num     = "750713712981"
aws_region      = "us-west-2"
aws_role        = "CloudAdmin"
kms_role        = "TF_Developers"
aws_r53_role    = "CloudAdmin"
account_num_r53 = "514712703977"

#Tags
AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits

#nlb
nlb_name = "tf-nlb-test-oxdi"
internal = true
#acm
acm_domain_name = "tfcnlb.nonprod.pge.com"

#s3
bucket_name = "ccoe-nlb-accesslogs-spoke-oxdi"
policy      = "s3_access_log_policy.json"

#kms
template_file_name = "kms_user_policy.json"
kms_name           = "tf-nlb-test-oxdi-kms"
kms_description    = "KMS key for NLB access logs"

#Ec2 variables
ec2_name = "ccoe-test-example"

ec2_instance_type = "t2.micro"
ec2_az            = "us-west-2a"

#Security group variables
nlb_sg_name        = "test-nlb-sg"
nlb_sg_description = "Security group for example usage with ec2"

nlb_cidr_ingress_rules = [{
  from             = 80,
  to               = 82,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 443,
    to               = 445,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
}]

sg_name = "test-ec2-nlb-sg"

sg_description = "Security group for example usage with ec2"

cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]