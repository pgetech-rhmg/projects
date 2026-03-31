account_num = "292217205150"
aws_region  = "us-west-2"
aws_role    = "Elevate_Ops"
user        = "grn0"

AppID              = "3696"     #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
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

ssm_arcpro_install_document_name   = "arcgis-pro-install"
ssm_arcpro_patch_install_document_name   = "arcgis-pro-patch-install"
ssm_document_type   = "Command" ## Valid document types include: Automation, Command, Package, Policy, and Session
ssm_document_format = "YAML"       ## Valid document types include: JSON and YAML
arcgis_pro_license_file = "esri/arcgis-enterprise/11-5/license/dev/ArcGISProAdvanced_SingleUse_1592641.prvc"
portal_license_url = "https://gogis-sor-test.nonprod.pge.com/portal"
portal_list = "https://gogis-sor-test.nonprod.pge.com/portal;https://pgegisportal.maps.arcgis.com"
