        run "rest_api_lambda_proxy" {
          command = apply
                            
          module {
            source = "./examples/rest_api_lambda_proxy"
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
rest_api_name        = "rest_api_test_aicg"
rest_api_description = "aws rest api for testing"
pVpcEndpoint = "vpce-0153835f967c30984"
resource_path_part = "resource"
method_http_method   = "GET"
method_authorization = "CUSTOM"
cors_enabled         = false
api_key_required     = false
method_request_parameters = { "method.request.header.X-Some-Header" = true }
authorizer_name                           = "api_test_authorizer"
authorizer_identity_validation_expression = "^(allow|deny|unauthorized)$"
integration_type                 = "AWS_PROXY"
integration_connection_type      = "INTERNET"
integration_http_method          = "POST"
integration_content_handling     = "CONVERT_TO_TEXT"
integration_cache_key_parameters = ["method.request.header.X-Some-Header"]
integration_cache_namespace      = "mycache"
integration_request_parameters = {
  "integration.request.header.X-Some-Header" = "'static'"
}
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"
usage_plan_key_type = "API_KEY"
request_validator_name                        = "test_request_validator"
request_validator_validate_request_parameters = true
method_response_status_code = "200"
api_gateway_integration_response_create = true
stage_name                  = "rest_api_stage"
stage_description           = "Manages an API Gateway Stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"
api_key_name = "sample_api_key"
lambda_sg_name        = "api_lamba_proxy_test_sg-stco"
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
iam_name        = "simple_lambda_test_policy-stco"
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
function_name              = "lambda-api-test-aicg"
runtime                    = "python3.9"
handler                    = "lambda_function.lambda_handler"
local_zip_source_directory = "lambda_source_code"
auth_function_name              = "lambda-rest-api-auth-test"
auth_handler                    = "index.handler"
auth_runtime                    = "nodejs20.x"
auth_local_zip_source_directory = "auth_lambda_source_code"
authorizer_iam_name        = "rest_api_gateway_auth_invocation-stco"
authorizer_iam_aws_service = ["apigateway.amazonaws.com"]
auth_lambda_sg_name = "auth_lambda_sg-stco"
        }
