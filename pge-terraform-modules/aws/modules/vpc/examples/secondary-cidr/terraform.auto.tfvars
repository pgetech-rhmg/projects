aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

AppID               = "1001"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment         = "Dev"      #Dev, Test, QA, Prod (only one)
DataClassification  = "Internal" #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS                = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner               = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance          = ["None"]
Order               = 8115205 #Order must be between 7 and 9 digits
create_vpc_sec_cidr = true

parameter_vpc_id_name     = "/vpc/id"
parameter_subnet_id1_name = "/vpc/2/privatesubnet1/id"
parameter_subnet_id2_name = "/vpc/2/privatesubnet2/id"
parameter_subnet_id3_name = "/vpc/2/privatesubnet3/id"
parameter_subnet_ida = "/dev/seconcidr/subnet1/id"
parameter_subnet_idb = "/dev/seconcidr/subnet2/id"
parameter_subnet_idc = "/dev/seconcidr/subnet3/id"


# ##### comment out when create_vpc_sec_cidr = false, the dafault value will be used 

subnet_a_cidr = "100.64.0.0/18"

subnet_b_cidr = "100.64.64.0/18"

subnet_c_cidr = "100.64.128.0/18"
subnet_a_name  = "subnet-azA-sec"
subnet_b_name  = "subnet-azB-sec"
subnet_c_name  = "subnet-azC-sec"   
parameter_transit_gateway = "/vpc/transit-gateway/id" ##### comment out when create_vpc_sec_cidr = false, the default value will be used 

parameter_sec_vpc_cidr = "100.64.0.0/16"