# tags
AppID                            = "3696" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment                      = "Dev"  #Dev, Test, QA, Prod (only one)
DataClassification               = "Internal" #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS                             = "Medium"   #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify                           = ["grn0@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner                            = ["grn0","KDMd","G1CR"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance                       = ["None"]
name                             = "imagebuilder-rhel-arcgis-server" #"Name of the project which will be used as a prefix for every resource."
Order                            = "8221088" #"A numeric value that defines the order of importance for this resource relative to other resources you may have."

# AWS Configuration
aws_region                       = "us-west-2"
account_num                      = "587401437202"
aws_role                         = "CloudAdmin"

# SSM Document Configuration
ssm_server_document_name   = "arcgis-server-11-5-configure"
ssm_document_type   = "Command" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "YAML"       ## Valid document types include: JSON and YAML
