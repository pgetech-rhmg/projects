# account_num = "056672152820"
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205                                           #Order tag is required and must be a number between 7 and 9 digits
#paramter_names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

#api_gateway_rest_api
rest_api_name        = "rest_api_test"
rest_api_description = "aws rest api for testing"

#rest_api policy
# pVpcEndpoint = "vpce-0a8e888a588d032de" # internal SharedServicesV2Prod VPC Endpoint (without going through F5)
pVpcEndpoint = "vpce-0153835f967c30984"

#aws_api_gateway_resource
resource_path_part = "api_gateway_resource"

#aws_api_gateway_method
method_http_method        = "GET"
method_request_parameters = { "method.request.header.X-Some-Header" = true }

#aws_api_gateway_integration
integration_type            = "HTTP"
integration_connection_type = "VPC_LINK"
integration_uri             = "https://www.google.com"
integration_http_method     = "GET"
integration_request_templates = {
  "application/json" = <<EOF
    {
       "body" : $input.json('$')
    }
      EOF

  "application/xml" = "#set($inputRoot = $input.path('$'))\n{ }"
}

integration_cache_key_parameters = ["method.request.header.X-Some-Header"]
integration_cache_namespace      = "mycachee"
integration_content_handling     = "CONVERT_TO_TEXT"
integration_passthrough_behavior = "WHEN_NO_MATCH"

#aws_api_gateway_method_response
method_response_status_code = "200"

#aws_api_gateway_integration_response
api_gateway_integration_response_create = true

#aws_api_gateway_model
model_name         = "testmodel"
model_content_type = "application/json"
model_schema       = <<EOF
 {
  "type": "object"
 }
 EOF

#aws_api_gateway_stage
stage_name                  = "rest_api_stage"
stage_description           = "Manages an API Gateway Stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5

#aws_api_gateway_request_validator
request_validator_name                        = "test_request_validator"
request_validator_validate_request_parameters = true

#aws_api_gateway_gateway_response
gateway_response_type = "UNAUTHORIZED"

#aws_api_gateway_method_settings
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"

#aws_api_gateway_client_certificate
api_gateway_client_certificate_create = true
client_certificate_description        = "Provides an API Gateway Client Certificate"

#aws_api_gateway_api_key
api_key_name = "sample_api_key"

#aws_api_gateway_usage_plan
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"

#aws_api_gateway_usage_plan_key
usage_plan_key_type = "API_KEY"

#aws_api_gateway_documentation_part
documentation_part_properties = "{\"description\":\"Example description\"}"
location_method               = "*"
location_type                 = "METHOD"
location_path                 = "/"

#aws_api_gateway_documentation_version
documentation_version     = "example_version"
documentation_description = "Manage an API Gateway Documentation Version"

#aws_api_gateway_vpc_link
vpc_link_name = "vpc_link_test"

alb_s3_bucket_name = "alb-s3-logs-example-ccoe"