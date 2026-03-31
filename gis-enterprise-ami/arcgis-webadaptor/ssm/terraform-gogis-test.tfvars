# tags
AppID              = "3696" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Test"      #Dev, Test, QA, Prod (only one)
DataClassification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
CRIS               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["lkg8@pge.com", "kdmd@pge.com", "grn0@pge.com"]
Owner              = ["lkg8", "kdmd", "grn0"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = "8221088" #Order must be between 7 and 9 digits"

# AWS Configuration
aws_region  = "us-west-2"
aws_role    = "Elevate_Ops"
user        = "grn0"

##############################
# Creating SSM-Document in JSON
##############################

ssm_webadaptor_config_document_name   = "arcgis-webadaptor-11-5-configure"
ssm_webadaptor_install_document_name  = "arcgis-webadaptor-11-5-install"
ssm_document_type   = "Command" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "YAML"       ## Valid document types include: JSON and YAML
