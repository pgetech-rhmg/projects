principal_orgid			= "o-7vgpdbu22o"
aws_account_id			= "514712703977"
app_name                = "pge-website-example"
aws_region              = "us-west-2"
environment             = "dev"

dataclassification      = "Public" # Public, Internal, Confidential, Restricted, Privileged (only one)
appid                   = "2102"   # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
cris                    = "Low"    # Cyber Risk Impact Score High, Medium, Low (only one)
notify                  = ["rhmg@pge.com", "def2@pge.com", "ghi3@pge.com"]
owner                   = ["rhmg", "def2", "ghi3"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
compliance              = ["None"]                 # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
order                   = 70056008                 #Order tag is required and must be a number between 7 and 9 digits
