aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"
kms_name    = "ccoe-rds-sqlserver-kms"
account_num = "750713712981"
aws_region  = "us-west-2"
user        = "rb1c"

identifier = "sqlserver-aicg"

multi_az            = true
monitoring_interval = 60
allocated_storage   = "20"
storage_type        = "gp2"
engine_version      = "15.00"
engine              = "sqlserver-ee"
family              = "sqlserver-ee-15.0"
license_model       = "license-included"
instance_class      = "db.t3.xlarge"
timezone            = "UTC"

allow_major_version_upgrade = true
username                    = "admin"
#password                    = "passalphatudsadsader"
manage_master_user_password          = true
maintenance_window                   = "sun:20:00-sun:21:00"
backup_window                        = "11:00-12:00"
max_allocated_storage                = 200
cpu_credit_balance_too_low_threshold = 150

create_iam_role_association = true
s3_bucket_arn               = "arn:aws:s3:::c7bh-test-rds-lzv2"
# Uncomment below variable when the DataClassification is not Internal or Public 
#storage_encrypted = true

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
}

/***************************************security group ********************************************************/
cidr_ingress_rules = [
  {
    from             = 1433,
    to               = 1433,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.112.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS Ingress rule 1"
  },
  {
    from             = 1433,
    to               = 1433,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.112.192/27"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS Ingress rule 2"
  },
  {
    from             = 1433,
    to               = 1433,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.112.160/27"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS Ingress rule 3"
  }

]
#Managed AD VPC CIDR.  Cannot be "0.0.0.0/0" as per SAF2.0 rules.
cidr_egress_rules = [
  {
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["10.90.112.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS egress rule 1"
  },
  {
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["10.90.112.192/27"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS egress rule 2"
  },
  {
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["10.90.112.160/27"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS egress rule 3"
  }


]

options = [
  {
    option_name                    = "TDE"
    db_security_group_memberships  = []
    vpc_security_group_memberships = []
    port                           = null
    version                        = ""
    option_settings                = []

  }

]