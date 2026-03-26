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

#variables for api_gateway_rest_api
variable "rest_api_name" {
  description = "The Name of the REST API"
  type        = string
}

variable "rest_api_description" {
  description = "The Description of the REST API"
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

# Variables for api_gateway_integration
variable "integration_type" {
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
  type        = string
}

variable "integration_connection_type" {
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  type        = string
}

variable "integration_uri" {
  description = "The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations."
  type        = string
}

variable "integration_http_method" {
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
  type        = string
}

variable "integration_request_templates" {
  description = "A map of the integration's request templates."
  type        = map(string)
}

variable "integration_content_handling" {
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT."
  type        = string
}

variable "integration_passthrough_behavior" {
  description = " The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used."
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

#variables for api_gateway_method_response
variable "method_response_status_code" {
  description = "The HTTP status code."
  type        = string
}

#variables for api_gateway_integration_response
variable "api_gateway_integration_response_create" {
  description = "Whether to create API Gateway Integration Response."
  type        = bool
}

#variables for api_gateway_model
variable "model_name" {
  description = "The name of the model."
  type        = string
}

variable "model_content_type" {
  description = "The content type of the model."
  type        = string
}

variable "model_schema" {
  description = "The schema of the model in a JSON form."
  type        = string
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

#api_gateway_request_validator
variable "request_validator_name" {
  description = "The name of the request validator."
  type        = string
}

variable "request_validator_validate_request_parameters" {
  description = "Boolean whether to validate request parameters. Defaults to false"
  type        = bool
}

#api_gateway_gateway_response
variable "gateway_response_type" {
  description = "The response type of the associated GatewayResponse."
  type        = string
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

#variables for api_gateway_client_certificate
variable "api_gateway_client_certificate_create" {
  description = "Whether to create API Gateway Client Certificate."
  type        = bool
}

variable "client_certificate_description" {
  description = "The description of the client certificate."
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

#variables for usage_plan_key
variable "usage_plan_key_type" {
  description = "The type of the API key resource."
  type        = string
}

#variables aws_api_gateway_documentation_part
variable "documentation_part_properties" {
  description = "A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published."
  type        = string
}

variable "location_method" {
  description = " The HTTP verb of a method. The default value is * for any method."
  type        = string
}

variable "location_type" {
  description = " The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST_BODY"
  type        = string
}

variable "location_path" {
  description = " The URL path of the target. The default value is / for the root resource."
  type        = string
}

#aws_api_gateway_documentation_version
variable "documentation_version" {
  description = " The version identifier of the API documentation snapshot."
  type        = string
}

variable "documentation_description" {
  description = " The description of the API documentation version."
  type        = string
}

#variables for api_gateway_vpc_link
variable "vpc_link_name" {
  description = "The name used to label and identify the VPC link."
  type        = string
}

#variable for optional_tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

####################################### variables of s3 ######################################
variable "alb_s3_bucket_name" {
  description = "Name of the S3 bucket for alb logs."
  type        = string
}


