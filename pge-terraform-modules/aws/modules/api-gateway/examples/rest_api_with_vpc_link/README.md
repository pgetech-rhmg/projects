<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Rest api with vpc link  user module example
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
| <a name="module_api_gateway_key"></a> [api\_gateway\_key](#module\_api\_gateway\_key) | ../../ | n/a |
| <a name="module_api_gateway_method"></a> [api\_gateway\_method](#module\_api\_gateway\_method) | ../../modules/rest_api_method | n/a |
| <a name="module_api_gateway_request_validator"></a> [api\_gateway\_request\_validator](#module\_api\_gateway\_request\_validator) | ../../modules/rest_api_request_validator | n/a |
| <a name="module_api_gateway_resource"></a> [api\_gateway\_resource](#module\_api\_gateway\_resource) | ../../modules/rest_api | n/a |
| <a name="module_api_gateway_stage"></a> [api\_gateway\_stage](#module\_api\_gateway\_stage) | ../../modules/rest_api_deployment_and_stage | n/a |
| <a name="module_api_gateway_usage_plan"></a> [api\_gateway\_usage\_plan](#module\_api\_gateway\_usage\_plan) | ../../modules/api_usage_plan | n/a |
| <a name="module_api_resource"></a> [api\_resource](#module\_api\_resource) | ../../modules/rest_api_resource | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_s3_bucket.lb-logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.allow-lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.allow-lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.api_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="input_alb_s3_bucket_name"></a> [alb\_s3\_bucket\_name](#input\_alb\_s3\_bucket\_name) | Name of the S3 bucket for alb logs. | `string` | n/a | yes |
| <a name="input_api_gateway_client_certificate_create"></a> [api\_gateway\_client\_certificate\_create](#input\_api\_gateway\_client\_certificate\_create) | Whether to create API Gateway Client Certificate. | `bool` | n/a | yes |
| <a name="input_api_gateway_integration_response_create"></a> [api\_gateway\_integration\_response\_create](#input\_api\_gateway\_integration\_response\_create) | Whether to create API Gateway Integration Response. | `bool` | n/a | yes |
| <a name="input_api_key_name"></a> [api\_key\_name](#input\_api\_key\_name) | The name of the API key. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_client_certificate_description"></a> [client\_certificate\_description](#input\_client\_certificate\_description) | The description of the client certificate. | `string` | n/a | yes |
| <a name="input_documentation_description"></a> [documentation\_description](#input\_documentation\_description) | The description of the API documentation version. | `string` | n/a | yes |
| <a name="input_documentation_part_properties"></a> [documentation\_part\_properties](#input\_documentation\_part\_properties) | A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published. | `string` | n/a | yes |
| <a name="input_documentation_version"></a> [documentation\_version](#input\_documentation\_version) | The version identifier of the API documentation snapshot. | `string` | n/a | yes |
| <a name="input_gateway_response_type"></a> [gateway\_response\_type](#input\_gateway\_response\_type) | The response type of the associated GatewayResponse. | `string` | n/a | yes |
| <a name="input_integration_cache_key_parameters"></a> [integration\_cache\_key\_parameters](#input\_integration\_cache\_key\_parameters) | A list of cache key parameters for the integration. | `list(string)` | n/a | yes |
| <a name="input_integration_cache_namespace"></a> [integration\_cache\_namespace](#input\_integration\_cache\_namespace) | The integration's cache namespace. | `string` | n/a | yes |
| <a name="input_integration_connection_type"></a> [integration\_connection\_type](#input\_integration\_connection\_type) | The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC\_LINK (for private connections between API Gateway and a network load balancer in a VPC). | `string` | n/a | yes |
| <a name="input_integration_content_handling"></a> [integration\_content\_handling](#input\_integration\_content\_handling) | Specifies how to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. | `string` | n/a | yes |
| <a name="input_integration_http_method"></a> [integration\_http\_method](#input\_integration\_http\_method) | The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST. | `string` | n/a | yes |
| <a name="input_integration_passthrough_behavior"></a> [integration\_passthrough\_behavior](#input\_integration\_passthrough\_behavior) | The integration passthrough behavior (WHEN\_NO\_MATCH, WHEN\_NO\_TEMPLATES, NEVER). Required if request\_templates is used. | `string` | n/a | yes |
| <a name="input_integration_request_templates"></a> [integration\_request\_templates](#input\_integration\_request\_templates) | A map of the integration's request templates. | `map(string)` | n/a | yes |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS\_PROXY (for Lambda proxy integration) and HTTP\_PROXY (for HTTP proxy integration). An HTTP or HTTP\_PROXY integration with a connection\_type of VPC\_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC. | `string` | n/a | yes |
| <a name="input_integration_uri"></a> [integration\_uri](#input\_integration\_uri) | The input's URI. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service\|service}:{path\|action}/{service\_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations. | `string` | n/a | yes |
| <a name="input_location_method"></a> [location\_method](#input\_location\_method) | The HTTP verb of a method. The default value is * for any method. | `string` | n/a | yes |
| <a name="input_location_path"></a> [location\_path](#input\_location\_path) | The URL path of the target. The default value is / for the root resource. | `string` | n/a | yes |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST\_BODY | `string` | n/a | yes |
| <a name="input_method_http_method"></a> [method\_http\_method](#input\_method\_http\_method) | The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY). | `string` | n/a | yes |
| <a name="input_method_request_parameters"></a> [method\_request\_parameters](#input\_method\_request\_parameters) | A map of request query string parameters and headers that should be passed to the integration. For example: request\_parameters = {"method.request.header.X-Some-Header" = true "method.request.querystring.some-query-param" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request. | `map(string)` | n/a | yes |
| <a name="input_method_response_status_code"></a> [method\_response\_status\_code](#input\_method\_response\_status\_code) | The HTTP status code. | `string` | n/a | yes |
| <a name="input_method_settings_method_path"></a> [method\_settings\_method\_path](#input\_method\_settings\_method\_path) | Method path defined as {resource\_path}/{http\_method} for an individual method override. | `string` | n/a | yes |
| <a name="input_model_content_type"></a> [model\_content\_type](#input\_model\_content\_type) | The content type of the model. | `string` | n/a | yes |
| <a name="input_model_name"></a> [model\_name](#input\_model\_name) | The name of the model. | `string` | n/a | yes |
| <a name="input_model_schema"></a> [model\_schema](#input\_model\_schema) | The schema of the model in a JSON form. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_pVpcEndpoint"></a> [pVpcEndpoint](#input\_pVpcEndpoint) | Vpc-endpoint for the resource policy | `string` | n/a | yes |
| <a name="input_request_validator_name"></a> [request\_validator\_name](#input\_request\_validator\_name) | The name of the request validator. | `string` | n/a | yes |
| <a name="input_request_validator_validate_request_parameters"></a> [request\_validator\_validate\_request\_parameters](#input\_request\_validator\_validate\_request\_parameters) | Boolean whether to validate request parameters. Defaults to false | `bool` | n/a | yes |
| <a name="input_resource_path_part"></a> [resource\_path\_part](#input\_resource\_path\_part) | The last path segment of this API resource | `string` | n/a | yes |
| <a name="input_rest_api_description"></a> [rest\_api\_description](#input\_rest\_api\_description) | The Description of the REST API | `string` | n/a | yes |
| <a name="input_rest_api_name"></a> [rest\_api\_name](#input\_rest\_api\_name) | The Name of the REST API | `string` | n/a | yes |
| <a name="input_settings_logging_level"></a> [settings\_logging\_level](#input\_settings\_logging\_level) | Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | The value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | The value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | The value of subnet id\_3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_stage_cache_cluster_enabled"></a> [stage\_cache\_cluster\_enabled](#input\_stage\_cache\_cluster\_enabled) | Specifies whether a cache cluster is enabled for the stage. | `bool` | n/a | yes |
| <a name="input_stage_cache_cluster_size"></a> [stage\_cache\_cluster\_size](#input\_stage\_cache\_cluster\_size) | The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `number` | n/a | yes |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | The description of the stage. | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | The name of the stage. | `string` | n/a | yes |
| <a name="input_usage_plan_description"></a> [usage\_plan\_description](#input\_usage\_plan\_description) | The description of a usage plan. | `string` | n/a | yes |
| <a name="input_usage_plan_key_type"></a> [usage\_plan\_key\_type](#input\_usage\_plan\_key\_type) | The type of the API key resource. | `string` | n/a | yes |
| <a name="input_usage_plan_name"></a> [usage\_plan\_name](#input\_usage\_plan\_name) | The name of the usage plan. | `string` | n/a | yes |
| <a name="input_vpc_link_name"></a> [vpc\_link\_name](#input\_vpc\_link\_name) | The name used to label and identify the VPC link. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_client_certificate_arn"></a> [api\_gateway\_client\_certificate\_arn](#output\_api\_gateway\_client\_certificate\_arn) | The Amazon Resource Name (ARN) of the client certificate |
| <a name="output_api_gateway_client_certificate_created_date"></a> [api\_gateway\_client\_certificate\_created\_date](#output\_api\_gateway\_client\_certificate\_created\_date) | The date when the client certificate was created |
| <a name="output_api_gateway_client_certificate_expiration_date"></a> [api\_gateway\_client\_certificate\_expiration\_date](#output\_api\_gateway\_client\_certificate\_expiration\_date) | The date when the client certificate will expire. |
| <a name="output_api_gateway_client_certificate_id"></a> [api\_gateway\_client\_certificate\_id](#output\_api\_gateway\_client\_certificate\_id) | The identifier of the client certificate |
| <a name="output_api_gateway_client_certificate_pem_encoded_certificate"></a> [api\_gateway\_client\_certificate\_pem\_encoded\_certificate](#output\_api\_gateway\_client\_certificate\_pem\_encoded\_certificate) | The identifier of the client certificate |
| <a name="output_api_gateway_client_certificate_tags_all"></a> [api\_gateway\_client\_certificate\_tags\_all](#output\_api\_gateway\_client\_certificate\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_api_gateway_deployment_created_date"></a> [api\_gateway\_deployment\_created\_date](#output\_api\_gateway\_deployment\_created\_date) | The creation date of the deployment |
| <a name="output_api_gateway_deployment_execution_arn"></a> [api\_gateway\_deployment\_execution\_arn](#output\_api\_gateway\_deployment\_execution\_arn) | The execution ARN to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function |
| <a name="output_api_gateway_deployment_id"></a> [api\_gateway\_deployment\_id](#output\_api\_gateway\_deployment\_id) | The ID for API Gateway Deployment |
| <a name="output_api_gateway_deployment_invoke_url"></a> [api\_gateway\_deployment\_invoke\_url](#output\_api\_gateway\_deployment\_invoke\_url) | The URL to invoke the API pointing to the stage |
| <a name="output_api_gateway_documentation_part_id"></a> [api\_gateway\_documentation\_part\_id](#output\_api\_gateway\_documentation\_part\_id) | The unique ID of the Documentation Part |
| <a name="output_api_gateway_model_id"></a> [api\_gateway\_model\_id](#output\_api\_gateway\_model\_id) | The ID of the model |
| <a name="output_api_gateway_request_validator_id"></a> [api\_gateway\_request\_validator\_id](#output\_api\_gateway\_request\_validator\_id) | The unique ID of the request validator |
| <a name="output_api_gateway_resource_id"></a> [api\_gateway\_resource\_id](#output\_api\_gateway\_resource\_id) | The ID of the API Gateway Resource |
| <a name="output_api_gateway_resource_path"></a> [api\_gateway\_resource\_path](#output\_api\_gateway\_resource\_path) | The path for API Gateway Resource with including all parent paths |
| <a name="output_api_gateway_rest_api_arn"></a> [api\_gateway\_rest\_api\_arn](#output\_api\_gateway\_rest\_api\_arn) | The Amazon Resource Name for API Gateway REST API |
| <a name="output_api_gateway_rest_api_created_date"></a> [api\_gateway\_rest\_api\_created\_date](#output\_api\_gateway\_rest\_api\_created\_date) | The creation date of the REST API |
| <a name="output_api_gateway_rest_api_execution_arn"></a> [api\_gateway\_rest\_api\_execution\_arn](#output\_api\_gateway\_rest\_api\_execution\_arn) | The execution arn part to be used in source arn when allowing API Gateway to invoke Lambda Function |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the REST API |
| <a name="output_api_gateway_rest_api_root_resource_id"></a> [api\_gateway\_rest\_api\_root\_resource\_id](#output\_api\_gateway\_rest\_api\_root\_resource\_id) | The Resource ID of the REST API's root |
| <a name="output_api_gateway_rest_api_tags_all"></a> [api\_gateway\_rest\_api\_tags\_all](#output\_api\_gateway\_rest\_api\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_api_gateway_stage_arn"></a> [api\_gateway\_stage\_arn](#output\_api\_gateway\_stage\_arn) | The Amazon Resource Name (ARN) for API Gateway Stage |
| <a name="output_api_gateway_stage_execution_arn"></a> [api\_gateway\_stage\_execution\_arn](#output\_api\_gateway\_stage\_execution\_arn) | The execution ARN to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function |
| <a name="output_api_gateway_stage_id"></a> [api\_gateway\_stage\_id](#output\_api\_gateway\_stage\_id) | The ID for API Gateway Stage |
| <a name="output_api_gateway_stage_invoke_url"></a> [api\_gateway\_stage\_invoke\_url](#output\_api\_gateway\_stage\_invoke\_url) | The URL to invoke the API pointing to the stage |
| <a name="output_api_gateway_stage_tags_all"></a> [api\_gateway\_stage\_tags\_all](#output\_api\_gateway\_stage\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_api_gateway_stage_web_acl_arn"></a> [api\_gateway\_stage\_web\_acl\_arn](#output\_api\_gateway\_stage\_web\_acl\_arn) | The ARN of the WebAcl associated with the Stage |
| <a name="output_api_gateway_usage_plan_api_stages"></a> [api\_gateway\_usage\_plan\_api\_stages](#output\_api\_gateway\_usage\_plan\_api\_stages) | The associated API stages of the usage plan |
| <a name="output_api_gateway_usage_plan_arn"></a> [api\_gateway\_usage\_plan\_arn](#output\_api\_gateway\_usage\_plan\_arn) | The Amazon Resource Name (ARN) of usage\_plan version |
| <a name="output_api_gateway_usage_plan_description"></a> [api\_gateway\_usage\_plan\_description](#output\_api\_gateway\_usage\_plan\_description) | The description of a usage plan |
| <a name="output_api_gateway_usage_plan_id"></a> [api\_gateway\_usage\_plan\_id](#output\_api\_gateway\_usage\_plan\_id) | The ID of the API resource |
| <a name="output_api_gateway_usage_plan_key_id"></a> [api\_gateway\_usage\_plan\_key\_id](#output\_api\_gateway\_usage\_plan\_key\_id) | The Id of a usage plan key |
| <a name="output_api_gateway_usage_plan_key_key_id"></a> [api\_gateway\_usage\_plan\_key\_key\_id](#output\_api\_gateway\_usage\_plan\_key\_key\_id) | The identifier of the API gateway key resource |
| <a name="output_api_gateway_usage_plan_key_key_type"></a> [api\_gateway\_usage\_plan\_key\_key\_type](#output\_api\_gateway\_usage\_plan\_key\_key\_type) | The type of a usage plan key. Currently, the valid key type is API\_KEY |
| <a name="output_api_gateway_usage_plan_key_name"></a> [api\_gateway\_usage\_plan\_key\_name](#output\_api\_gateway\_usage\_plan\_key\_name) | The name of a usage plan key |
| <a name="output_api_gateway_usage_plan_key_usage_plan_id"></a> [api\_gateway\_usage\_plan\_key\_usage\_plan\_id](#output\_api\_gateway\_usage\_plan\_key\_usage\_plan\_id) | The ID of the API resource |
| <a name="output_api_gateway_usage_plan_key_value"></a> [api\_gateway\_usage\_plan\_key\_value](#output\_api\_gateway\_usage\_plan\_key\_value) | The value of a usage plan key |
| <a name="output_api_gateway_usage_plan_name"></a> [api\_gateway\_usage\_plan\_name](#output\_api\_gateway\_usage\_plan\_name) | The name of the usage plan |
| <a name="output_api_gateway_usage_plan_product_code"></a> [api\_gateway\_usage\_plan\_product\_code](#output\_api\_gateway\_usage\_plan\_product\_code) | The AWS Marketplace product identifier to associate with the usage plan as a SaaS product on AWS Marketplace |
| <a name="output_api_gateway_usage_plan_quota_settings"></a> [api\_gateway\_usage\_plan\_quota\_settings](#output\_api\_gateway\_usage\_plan\_quota\_settings) | The quota of the usage plan |
| <a name="output_api_gateway_usage_plan_tags_all"></a> [api\_gateway\_usage\_plan\_tags\_all](#output\_api\_gateway\_usage\_plan\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_api_gateway_usage_plan_throttle_settings"></a> [api\_gateway\_usage\_plan\_throttle\_settings](#output\_api\_gateway\_usage\_plan\_throttle\_settings) | The throttling limits of the usage plan |
| <a name="output_api_gateway_vpc_link_id"></a> [api\_gateway\_vpc\_link\_id](#output\_api\_gateway\_vpc\_link\_id) | The identifier of the VpcLink |
| <a name="output_api_gateway_vpc_link_tags_all"></a> [api\_gateway\_vpc\_link\_tags\_all](#output\_api\_gateway\_vpc\_link\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->