        run "rest_api_with_vpc_link" {
          command = apply
                            
          module {
            source = "./examples/rest_api_with_vpc_link"
          }
        }
        
        variables {
        account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
AppID       = "1001" 
Environment = "Dev"  
DataClassification = "Internal"                                       
CRIS               = "Low"                                            
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] 
Owner              = ["abc1", "def2", "ghi3"]                         
Compliance         = ["None"]
Order              = 8115205                                           
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
rest_api_name        = "rest_api_test"
rest_api_description = "aws rest api for testing"
pVpcEndpoint = "vpce-0153835f967c30984"
resource_path_part = "api_gateway_resource"
method_http_method        = "GET"
method_request_parameters = { "method.request.header.X-Some-Header" = true }
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
method_response_status_code = "200"
api_gateway_integration_response_create = true
model_name         = "testmodel"
model_content_type = "application/json"
model_schema       = <<EOF
 {
  "type": "object"
 }
 EOF
stage_name                  = "rest_api_stage"
stage_description           = "Manages an API Gateway Stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5
request_validator_name                        = "test_request_validator"
request_validator_validate_request_parameters = true
gateway_response_type = "UNAUTHORIZED"
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"
api_gateway_client_certificate_create = true
client_certificate_description        = "Provides an API Gateway Client Certificate"
api_key_name = "sample_api_key"
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"
usage_plan_key_type = "API_KEY"
documentation_part_properties = "{\"description\":\"Example description\"}"
location_method               = "*"
location_type                 = "METHOD"
location_path                 = "/"
documentation_version     = "example_version"
documentation_description = "Manage an API Gateway Documentation Version"
vpc_link_name = "vpc_link_test"
alb_s3_bucket_name = "alb-s3-logs-example-ccoe"
        }
