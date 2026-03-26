variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for parameter store paramter_names
variable "ssm_parameter_vpc_id" {
  description = "The value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "The value of subnet id_1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "The value of subnet id_2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "The value of subnet id_3 stored in ssm parameter"
  type        = string
}

#variables for api_gateway_rest_api
variable "rest_api_name" {
  description = "The Name of the REST API"
  type        = string
}

variable "rest_api_description" {
  description = "The Description of the REST API"
  type        = string
}

#rest_api policy
variable "policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}

variable "pVpcEndpoint" {
  description = "Vpc-endpoint for the resource policy"
  type        = string
}

#variables for api_gateway_resource
variable "resource_path_part" {
  description = "The last path segment of this API resource"
  type        = string
}

#Variables for api_gateway_method
variable "method_http_method" {
  description = "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
  type        = string
}

variable "method_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
  type        = map(string)
}

# variables for api_gateway_authorizer
variable "authorizer_name" {
  description = "The name of the authorizer."
  type        = string
}

variable "authorizer_identity_source" {
  description = "The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. \"method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName\"."
  type        = string
}

variable "authorizer_type" {
  description = "The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN."
  type        = string
}

# Variables for api_gateway_integration
variable "integration_type" {
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
  type        = string
}

variable "integration_http_method" {
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
  type        = string
}

variable "integration_content_handling" {
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT."
  type        = string
}

variable "integration_connection_type" {
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  type        = string
}

variable "integration_cache_key_parameters" {
  description = "A list of cache key parameters for the integration."
  type        = list(string)
}

variable "integration_cache_namespace" {
  description = "The integration's cache namespace."
  type        = string
}

variable "integration_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { \"integration.request.header.X-Some-Other-Header\" = \"method.request.header.X-Some-Header\" }."
  type        = map(string)
}

#api_gateway_request_validator
variable "request_validator_name" {
  description = "The name of the request validator."
  type        = string
}

variable "request_validator_validate_request_parameters" {
  description = "Boolean whether to validate request parameters. Defaults to false"
  type        = bool
}

# variables for api_gateway_method_response
variable "method_response_status_code" {
  description = "The HTTP status code."
  type        = string
}

# variables for api_gateway_integration_response
variable "api_gateway_integration_response_create" {
  description = "Whether to create API Gateway Integration Response."
  type        = bool
}

#variables for api_gateway_stage
variable "stage_name" {
  description = "The name of the stage."
  type        = string
}

variable "stage_description" {
  description = "The description of the stage."
  type        = string
}

variable "stage_cache_cluster_enabled" {
  description = "Specifies whether a cache cluster is enabled for the stage."
  type        = bool
}

variable "stage_cache_cluster_size" {
  description = "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  type        = number
}

# api_gateway_method_settings
variable "method_settings_method_path" {
  description = "Method path defined as {resource_path}/{http_method} for an individual method override."
  type        = string
}

variable "settings_logging_level" {
  description = "Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = string
}

#api_gateway_api_key
variable "api_key_name" {
  description = "The name of the API key."
  type        = string
}

#variables for api_gateway_usage_plan
variable "usage_plan_name" {
  description = "The name of the usage plan."
  type        = string
}

variable "usage_plan_description" {
  description = " The description of a usage plan."
  type        = string
}

# variables for usage_plan_key
variable "usage_plan_key_type" {
  description = "The type of the API key resource. Currently, the valid key type is API_KEY."
  type        = string
}

#variables for authorizer_iam_role
variable "authorizer_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "authorizer_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#variables for sns_topic
variable "snstopic_name" {
  description = "name of the sns topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

#variables for sns_iam_role
variable "sns_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "sns_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

# Variables for lambda_function
variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = " Identifier of the function's runtime"
  type        = string
}

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
  type        = string
}

#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

#variable for optional_tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

#variables for security_group_lambda
variable "lambda_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "lambda_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "lambda_sg_name" {
  description = "name of the security group"
  type        = string
}

variable "lambda_sg_description" {
  description = "vpc id for security group"
  type        = string
}

#variable tags
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
  default     = null
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
  default     = null
}

#Variables for api_gateway_method
variable "method_post_http_method" {
  description = "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
  type        = string
}

variable "method_post_authorization" {
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
  type        = string
}

variable "method_post_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
  type        = map(string)
}


######## Variables for api_gateway_integration
variable "post_integration_type" {
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
  type        = string
}

variable "post_integration_http_method" {
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
  type        = string
}

variable "post_integration_content_handling" {
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT."
  type        = string
}

variable "post_integration_connection_type" {
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  type        = string
}

variable "post_integration_cache_key_parameters" {
  description = "A list of cache key parameters for the integration."
  type        = list(string)
}

variable "post_integration_cache_namespace" {
  description = "The integration's cache namespace."
  type        = string
}

variable "post_integration_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { \"integration.request.header.X-Some-Other-Header\" = \"method.request.header.X-Some-Header\" }."
  type        = map(string)
}

############ OPTIONS method ########

#Variables for api_gateway_method
variable "method_options_http_method" {
  description = "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
  type        = string
}

variable "method_options_authorization" {
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
  type        = string
}


variable "method_options_api_key_required" {
  description = "Specify if the method requires an API key"
  type        = bool
}

variable "method_options_cors_enabled" {
  description = "Specify if CORS is enabled"
  type        = bool
}

variable "method_options_response_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
  type        = map(string)
}

######## Variables for api_gateway_integration
variable "options_integration_type" {
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
  type        = string
}

variable "options_integration_connection_type" {
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  type        = string
}


variable "options_integration_response_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { \"integration.request.header.X-Some-Other-Header\" = \"method.request.header.X-Some-Header\" }."
  type        = map(string)
}

########


variable "stage_variables" {
  description = "A map that defines the stage variables."
  type        = map(string)
  default     = null
}

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = ""
}

variable "method_post_api_key_required" {
  description = "Specify if the method requires an API key"
  type        = bool
}

variable "method_post_cors_enabled" {
  description = "Specify if CORS is enabled"
  type        = bool
}


variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}