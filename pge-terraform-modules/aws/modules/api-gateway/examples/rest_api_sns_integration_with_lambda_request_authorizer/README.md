<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Rest api SNS integration with request authorizer user module example
Terraform module which creates SAF2.0 API Gateway in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway_authorizer"></a> [api\_gateway\_authorizer](#module\_api\_gateway\_authorizer) | ../../modules/rest_api_authorizer | n/a |
| <a name="module_api_gateway_key"></a> [api\_gateway\_key](#module\_api\_gateway\_key) | ../../ | n/a |
| <a name="module_api_gateway_method"></a> [api\_gateway\_method](#module\_api\_gateway\_method) | ../../modules/rest_api_method | n/a |
| <a name="module_api_gateway_request_validator"></a> [api\_gateway\_request\_validator](#module\_api\_gateway\_request\_validator) | ../../modules/rest_api_request_validator | n/a |
| <a name="module_api_gateway_resource"></a> [api\_gateway\_resource](#module\_api\_gateway\_resource) | ../../modules/rest_api | n/a |
| <a name="module_api_gateway_stage"></a> [api\_gateway\_stage](#module\_api\_gateway\_stage) | ../../modules/rest_api_deployment_and_stage | n/a |
| <a name="module_api_gateway_usage_plan"></a> [api\_gateway\_usage\_plan](#module\_api\_gateway\_usage\_plan) | ../../modules/api_usage_plan | n/a |
| <a name="module_api_resource"></a> [api\_resource](#module\_api\_resource) | ../../modules/rest_api_resource | n/a |
| <a name="module_authorizer_iam_role"></a> [authorizer\_iam\_role](#module\_authorizer\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_sns_iam_role"></a> [aws\_sns\_iam\_role](#module\_aws\_sns\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_sns_api"></a> [sns\_api](#module\_sns\_api) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_permission.apigw_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.api_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline_policy_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_api_gateway_integration_response_create"></a> [api\_gateway\_integration\_response\_create](#input\_api\_gateway\_integration\_response\_create) | Whether to create API Gateway Integration Response. | `bool` | n/a | yes |
| <a name="input_api_key_name"></a> [api\_key\_name](#input\_api\_key\_name) | The name of the API key. | `string` | n/a | yes |
| <a name="input_api_key_required"></a> [api\_key\_required](#input\_api\_key\_required) | Specify if the method requires an API key | `bool` | n/a | yes |
| <a name="input_authorizer_iam_aws_service"></a> [authorizer\_iam\_aws\_service](#input\_authorizer\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_authorizer_iam_name"></a> [authorizer\_iam\_name](#input\_authorizer\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_authorizer_identity_source"></a> [authorizer\_identity\_source](#input\_authorizer\_identity\_source) | The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. "method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName". | `string` | n/a | yes |
| <a name="input_authorizer_name"></a> [authorizer\_name](#input\_authorizer\_name) | The name of the authorizer. | `string` | n/a | yes |
| <a name="input_authorizer_type"></a> [authorizer\_type](#input\_authorizer\_type) | The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO\_USER\_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cors_enabled"></a> [cors\_enabled](#input\_cors\_enabled) | Specify if CORS is enabled | `bool` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_integration_cache_key_parameters"></a> [integration\_cache\_key\_parameters](#input\_integration\_cache\_key\_parameters) | A list of cache key parameters for the integration. | `list(string)` | n/a | yes |
| <a name="input_integration_cache_namespace"></a> [integration\_cache\_namespace](#input\_integration\_cache\_namespace) | The integration's cache namespace. | `string` | n/a | yes |
| <a name="input_integration_connection_type"></a> [integration\_connection\_type](#input\_integration\_connection\_type) | The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC\_LINK (for private connections between API Gateway and a network load balancer in a VPC). | `string` | n/a | yes |
| <a name="input_integration_content_handling"></a> [integration\_content\_handling](#input\_integration\_content\_handling) | Specifies how to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. | `string` | n/a | yes |
| <a name="input_integration_http_method"></a> [integration\_http\_method](#input\_integration\_http\_method) | The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST. | `string` | n/a | yes |
| <a name="input_integration_request_parameters"></a> [integration\_request\_parameters](#input\_integration\_request\_parameters) | A map of request query string parameters and headers that should be passed to the backend responder. For example: request\_parameters = { "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header" }. | `map(string)` | n/a | yes |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS\_PROXY (for Lambda proxy integration) and HTTP\_PROXY (for HTTP proxy integration). An HTTP or HTTP\_PROXY integration with a connection\_type of VPC\_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC. | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_lambda_cidr_egress_rules"></a> [lambda\_cidr\_egress\_rules](#input\_lambda\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_cidr_ingress_rules"></a> [lambda\_cidr\_ingress\_rules](#input\_lambda\_cidr\_ingress\_rules) | variables for security\_group\_lambda | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lambda_sg_description"></a> [lambda\_sg\_description](#input\_lambda\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_lambda_sg_name"></a> [lambda\_sg\_name](#input\_lambda\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_local_zip_source_directory"></a> [local\_zip\_source\_directory](#input\_local\_zip\_source\_directory) | Package entire contents of this directory into the archive | `string` | n/a | yes |
| <a name="input_method_authorization"></a> [method\_authorization](#input\_method\_authorization) | The type of authorization used for the method (NONE, CUSTOM, AWS\_IAM, COGNITO\_USER\_POOLS). | `string` | n/a | yes |
| <a name="input_method_http_method"></a> [method\_http\_method](#input\_method\_http\_method) | The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY). | `string` | n/a | yes |
| <a name="input_method_request_parameters"></a> [method\_request\_parameters](#input\_method\_request\_parameters) | A map of request query string parameters and headers that should be passed to the integration. For example: request\_parameters = {"method.request.header.X-Some-Header" = true "method.request.querystring.some-query-param" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request. | `map(string)` | n/a | yes |
| <a name="input_method_response_status_code"></a> [method\_response\_status\_code](#input\_method\_response\_status\_code) | The HTTP status code. | `string` | n/a | yes |
| <a name="input_method_settings_method_path"></a> [method\_settings\_method\_path](#input\_method\_settings\_method\_path) | Method path defined as {resource\_path}/{http\_method} for an individual method override. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_pVpcEndpoint"></a> [pVpcEndpoint](#input\_pVpcEndpoint) | Vpc-endpoint for the resource policy | `string` | n/a | yes |
| <a name="input_request_validator_name"></a> [request\_validator\_name](#input\_request\_validator\_name) | The name of the request validator. | `string` | n/a | yes |
| <a name="input_request_validator_validate_request_parameters"></a> [request\_validator\_validate\_request\_parameters](#input\_request\_validator\_validate\_request\_parameters) | Boolean whether to validate request parameters. Defaults to false | `bool` | n/a | yes |
| <a name="input_resource_path_part"></a> [resource\_path\_part](#input\_resource\_path\_part) | The last path segment of this API resource | `string` | n/a | yes |
| <a name="input_rest_api_description"></a> [rest\_api\_description](#input\_rest\_api\_description) | The Description of the REST API | `string` | n/a | yes |
| <a name="input_rest_api_name"></a> [rest\_api\_name](#input\_rest\_api\_name) | The Name of the REST API | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_settings_logging_level"></a> [settings\_logging\_level](#input\_settings\_logging\_level) | Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. | `string` | n/a | yes |
| <a name="input_sns_iam_aws_service"></a> [sns\_iam\_aws\_service](#input\_sns\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_sns_iam_name"></a> [sns\_iam\_name](#input\_sns\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the sns topic | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | The value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | The value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_stage_cache_cluster_enabled"></a> [stage\_cache\_cluster\_enabled](#input\_stage\_cache\_cluster\_enabled) | Specifies whether a cache cluster is enabled for the stage. | `bool` | n/a | yes |
| <a name="input_stage_cache_cluster_size"></a> [stage\_cache\_cluster\_size](#input\_stage\_cache\_cluster\_size) | The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `number` | n/a | yes |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | The description of the stage. | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | The name of the stage. | `string` | n/a | yes |
| <a name="input_usage_plan_description"></a> [usage\_plan\_description](#input\_usage\_plan\_description) | The description of a usage plan. | `string` | n/a | yes |
| <a name="input_usage_plan_key_type"></a> [usage\_plan\_key\_type](#input\_usage\_plan\_key\_type) | The type of the API key resource. Currently, the valid key type is API\_KEY. | `string` | n/a | yes |
| <a name="input_usage_plan_name"></a> [usage\_plan\_name](#input\_usage\_plan\_name) | The name of the usage plan. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_request_validator_id"></a> [api\_gateway\_request\_validator\_id](#output\_api\_gateway\_request\_validator\_id) | The unique ID of the request validator |
| <a name="output_api_gateway_resource_id"></a> [api\_gateway\_resource\_id](#output\_api\_gateway\_resource\_id) | The ID of the API Gateway Resource |
| <a name="output_api_gateway_resource_path"></a> [api\_gateway\_resource\_path](#output\_api\_gateway\_resource\_path) | The path for API Gateway Resource with including all parent paths |
| <a name="output_api_gateway_rest_api_arn"></a> [api\_gateway\_rest\_api\_arn](#output\_api\_gateway\_rest\_api\_arn) | The Amazon Resource Name for API Gateway REST API |
| <a name="output_api_gateway_rest_api_created_date"></a> [api\_gateway\_rest\_api\_created\_date](#output\_api\_gateway\_rest\_api\_created\_date) | The creation date of the REST API |
| <a name="output_api_gateway_rest_api_execution_arn"></a> [api\_gateway\_rest\_api\_execution\_arn](#output\_api\_gateway\_rest\_api\_execution\_arn) | The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the REST API |
| <a name="output_api_gateway_rest_api_root_resource_id"></a> [api\_gateway\_rest\_api\_root\_resource\_id](#output\_api\_gateway\_rest\_api\_root\_resource\_id) | The Resource ID of the REST API's root |
| <a name="output_api_gateway_rest_api_tags_all"></a> [api\_gateway\_rest\_api\_tags\_all](#output\_api\_gateway\_rest\_api\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |

<!-- END_TF_DOCS -->