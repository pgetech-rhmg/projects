account_num = "874578101770"
aws_region  = "us-west-2"
aws_role    = "Elevate_Ops"
user        = "grn0"

# tags
app_id            = "3605"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
environment        = "Dev"      #Dev, Test, QA, Prod (only one)
data_classification = "Internal" #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BCSI (only one)
cris               = "Low"      #"Cyber Risk Impact Score High, Medium, Low (only one)"
notify             = ["lkg8@pge.com", "kdmd@pge.com", "grn0@pge.com"]
owner              = ["lkg8", "kdmd", "grn0"] #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
compliance         = ["None"]
order              = "8221088" #Order must be between 7 and 9 digits"
optional_tags = {
  AppName                             = "entgis"
  DRTier                              = "N/A"
  MCP                                 = "NoMCP"
  CreatedBy                           = "LKG8"
}

##############################
# Creating SSM-Document in YAML
##############################

ssm_fmecore_install_document_name               = "fmeflow-core-windows-command"
ssm_arcgis_server_install_document_name         = "arcgis-server-115-windows-command"
ssm_fmeflow_automation_document_name            = "fmeflow-core-windows-install"
ssm_fmeengine_install_document_name             = "fmeflow-engine-windows-command"
ssm_arcgis_fme_engine_automation_document_name  = "fmeflow-engine-windows-install"
ssm_document_format                         = "YAML" ## Valid document types include: JSON and YAML
