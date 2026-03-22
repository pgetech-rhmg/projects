account_num = "587401437202"
aws_region  = "us-west-2"
aws_role    = "Elevate_Ops"
user        = "grn0"

app_id              = "3696"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
environment         = "Dev"      #Dev, Test, QA, Prod (only one)
data_classification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
cris                = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
notify              = ["lkg8@pge.com", "kdmd@pge.com", "grn0@pge.com"]
owner               = ["lkg8", "kdmd", "grn0"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
compliance          = ["None"]
order               = "8221088" #Order must be between 7 and 9 digits"
optional_tags = {
  AppName                             = "gogis"
  DRTier                              = "N/A"
  MCP                                 = "NoMCP"
  CreatedBy                           = "LKG8"
}

##############################
# Creating SSM-Document in YAML
##############################

ssm_fme_form_install_document_name   = "fme-form-install"
ssm_document_type   = "Command" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "YAML"       ## Valid document types include: JSON and YAML
