appid = "3605" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"

dataclassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
cris               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
notify             = ["lkg8@pge.com", "grn0@pge.com", "kdmd@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
owner              = ["lkg8@pge.com", "grn0@pge.com", "kdmd@pge.com"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
compliance         = ["None"]
order              = "8221088" #"Order Number of the project for AWS Resource Cost"

availabilityzonea = "us-west-2a" #"Availability Zone to be used by machine creation"
availabilityzoneb = "us-west-2b" #"Availability Zone to be used by machine creation"
availabilityzonec = "us-west-2c" #"Availability Zone to be used by machine creation"

optional_tags = {
  pge_team            = "elevate-platform-engineering"
  AppName             = "eogis"  #AppName in AMPS
  DRTier              = "Tier 1" #DRTier value in AMPS d d
  MCP                 = "NoMCP"  #MCP Value in AMPS
  Org                 = "Information Technology"
  CreatedBy           = "lkg8@pge.com" ### LanID of the person who created this
  ccoe_patch_schedule = ""             # 
}


metadata_http_endpoint = "enabled"