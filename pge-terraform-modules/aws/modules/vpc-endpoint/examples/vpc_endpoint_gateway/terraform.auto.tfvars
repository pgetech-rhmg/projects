aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"


AppID              = "1001"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"      #Dev, Test, QA, Prod (only one)
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order = 8115205 #Order must be between 7 and 9 digits

#parameter store names
vpc_id_name = "/vpc/id"

service_name    = "com.amazonaws.us-west-2.s3"
route_table_ids = ["rtb-02b58d41c08ef6e9f"]
