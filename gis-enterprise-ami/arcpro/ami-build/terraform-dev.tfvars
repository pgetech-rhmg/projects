account_num = "587401437202"
aws_region  = "us-west-2"
aws_role    = "Elevate_Ops"
user        = "grn0"

AppID              = "3605"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Test"      #Dev, Test, QA, Prod (only one)
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["lkg8@pge.com", "kdmd@pge.com", "grn0@pge.com"]
Owner              = ["lkg8", "kdmd", "grn0"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = "8221088" #Order must be between 7 and 9 digits"


##############################
# Creating SSM-Document in YAML
##############################

ssm_document_name   = "arcgis-pro-3-5-install"
ssm_document_type   = "Automation" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "YAML"       ## Valid document types include: JSON and YAML
