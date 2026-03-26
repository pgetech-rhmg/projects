aws_region  = "us-west-2"
account_num = "056672152820"
aws_role    = "CloudAdmin"

# Tag variables

AppID              = "1001"                                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order = 8115205 #Order must be between 7 and 9 digits
optional_tags = { service = "glue" }

#Common variable name for resources

name = "example"

# glue schema variables
glue_schema_name       = "Test-iac-3"
glue_data_format       = "AVRO"
glue_compatibility     = "NONE"
glue_schema_definition = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
