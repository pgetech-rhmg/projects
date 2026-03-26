aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"


tags = {
  Owner       = "abc1_def2_ghi3" #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader"
  AppID       = "APP-1001"       #Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  Environment = "Dev"            #Dev, Test, QA, Prod (only one environment) 
  # If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
  # detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
  DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
  Compliance         = "None"
  CRIS               = "High" #"Cyber Risk Impact Score High, Medium, Low (only one)"
  Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
  Order              = 8115205 #Order must be between 7 and 9 digits"
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

