        run "rest_api_multiple_methods_with_cors_support" {
          command = apply
                            
          module {
            source = "./examples/rest_api_multiple_methods_with_cors_support"
          }
        }
        
        variables {
        account_num = "750713712981"
aws_role    = "CloudAdmin"
aws_region  = "us-west-2"
kms_role    = "SuperAdmin" 
AppID       = "1001" 
Environment = "Dev"  
DataClassification = "Internal"                                       
CRIS               = "Low"                                            
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] 
Owner              = ["abc1", "def2", "ghi3"]                         
Compliance         = ["None"]
Order              = 8115205                                           
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/privatesubnet3/id"
rest_api_name        = "rest_api_test_sns"
rest_api_description = "aws rest api for testing"
pVpcEndpoint     = "vpce-0153835f967c30984"
policy_file_name = "policy.json"
resource_path_part = "resource"
method_http_method        = "GET"
method_request_parameters = { "method.request.header.X-Some-Header" = true }
authorizer_name            = "test_authorizer"
authorizer_type            = "REQUEST"
authorizer_identity_source = "method.request.header.headerauth1,method.request.querystring.QueryString1,stageVariables.StageVar1"
integration_type                 = "AWS"
integration_connection_type      = "INTERNET"
integration_http_method          = "POST"
integration_content_handling     = "CONVERT_TO_TEXT"
integration_cache_key_parameters = ["method.request.header.X-Some-Header", "integration.request.header.X-Some-Header"]
integration_cache_namespace      = "mycache"
integration_request_parameters = {
  "integration.request.header.X-Some-Header" = "'static'"
}
method_post_api_key_required   = false
method_post_cors_enabled       = false
method_post_http_method        = "POST"
method_post_authorization      = "CUSTOM"
method_post_request_parameters = { "method.request.header.X-Some-Header" = true, "method.request.querystring.Message" = true, "method.request.querystring.topicArn" = true }
post_integration_type                 = "AWS"
post_integration_connection_type      = "INTERNET"
post_integration_http_method          = "POST"
post_integration_content_handling     = "CONVERT_TO_TEXT"
post_integration_cache_key_parameters = ["method.request.header.X-Some-Header", "integration.request.header.X-Some-Header"]
post_integration_cache_namespace      = "mycache"
post_integration_request_parameters = {
  "integration.request.header.X-Some-Header" = "'static'",
  "integration.request.querystring.Message"  = "method.request.querystring.Message",
  "integration.request.querystring.TopicArn" = "method.request.querystring.topicArn"
}
method_options_api_key_required = false
method_options_cors_enabled     = true 
method_options_http_method      = "OPTIONS"
method_options_authorization    = "NONE"
method_options_response_parameters = {
  "method.response.header.Access-Control-Allow-Headers" = true,
  "method.response.header.Access-Control-Allow-Methods" = true,
"method.response.header.Access-Control-Allow-Origin" = true }
options_integration_type            = "MOCK"
options_integration_connection_type = "INTERNET"
options_integration_response_parameters = {
  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
  "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
}
request_validator_name                        = "test_request_validator"
request_validator_validate_request_parameters = true
method_response_status_code = "200"
api_gateway_integration_response_create = true
stage_name                  = "rest_api_stage"
stage_description           = "Manages an API Gateway Stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5
stage_variables = {
  "StageVar1" = "stageValue1"
}
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"
api_key_name = "sample_api_key"
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"
usage_plan_key_type = "API_KEY"
authorizer_iam_name        = "api_authorizer_test_role"
authorizer_iam_aws_service = ["apigateway.amazonaws.com"]
snstopic_name         = "sns_test_api"
snstopic_display_name = "sns topic for testing with api"
sns_iam_name        = "sns_api_role"
sns_iam_aws_service = ["apigateway.amazonaws.com"]
endpoint = ["aicg@pge.com"] 
protocol = "email"          
lambda_sg_name        = "rest_api_sns_lamba_sg"
lambda_sg_description = "Security group for example usage with lambda"
lambda_cidr_ingress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23", "10.90.112.128/25", "10.91.128.0/22"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23", "10.90.112.128/25", "10.91.128.0/22"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
}]
lambda_cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]
iam_name        = "simple_api_lambda_policy"
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
function_name              = "lambda-api-test"
runtime                    = "nodejs20.x"
handler                    = "index.handler"
local_zip_source_directory = "lambda_source_code"
kms_name           = "lambda-rest-api-cmk-key"
kms_description    = "CMK for encrypting lambda"
template_file_name = "kms_user_policy.json"
        }
