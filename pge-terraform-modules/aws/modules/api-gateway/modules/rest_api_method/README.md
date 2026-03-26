<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Method
Terraform module which creates SAF2.0 API Gateway Rest Api in AWS

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_integration.api_gateway_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.api_gateway_integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.api_gateway_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.api_gateway_method_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_integration_response_create"></a> [api\_gateway\_integration\_response\_create](#input\_api\_gateway\_integration\_response\_create) | Whether to create API Gateway Integration Response. | `bool` | `false` | no |
| <a name="input_authorization"></a> [authorization](#input\_authorization) | method\_authorization:<br/>   The type of authorization used for the method (NONE, CUSTOM, AWS\_IAM).<br/>method\_authorization\_id:<br/>  The authorizer id to be used when the authorization is CUSTOM<br/>api\_key\_required:<br/>  "Specify if the method requires an API key"<br/>cors\_enabled:<br/>   "Specify if CORS is enabled" | <pre>object({<br/>    method_authorization    = string<br/>    method_authorization_id = string<br/>    api_key_required        = bool<br/>    cors_enabled            = bool<br/>  })</pre> | <pre>{<br/>  "api_key_required": true,<br/>  "cors_enabled": false,<br/>  "method_authorization": "NONE",<br/>  "method_authorization_id": null<br/>}</pre> | no |
| <a name="input_integration_cache_key_parameters"></a> [integration\_cache\_key\_parameters](#input\_integration\_cache\_key\_parameters) | A list of cache key parameters for the integration. | `list(string)` | `null` | no |
| <a name="input_integration_cache_namespace"></a> [integration\_cache\_namespace](#input\_integration\_cache\_namespace) | The integration's cache namespace. | `string` | `null` | no |
| <a name="input_integration_connection_id"></a> [integration\_connection\_id](#input\_integration\_connection\_id) | The id of the VpcLink used for the integration. Required if connection\_type is VPC\_LINK | `string` | `null` | no |
| <a name="input_integration_connection_type"></a> [integration\_connection\_type](#input\_integration\_connection\_type) | The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC\_LINK (for private connections between API Gateway and a network load balancer in a VPC). | `string` | `null` | no |
| <a name="input_integration_content_handling"></a> [integration\_content\_handling](#input\_integration\_content\_handling) | Specifies how to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through. | `string` | `null` | no |
| <a name="input_integration_credentials"></a> [integration\_credentials](#input\_integration\_credentials) | The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::*:user/*. | `string` | `null` | no |
| <a name="input_integration_http_method"></a> [integration\_http\_method](#input\_integration\_http\_method) | The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST. | `string` | `null` | no |
| <a name="input_integration_passthrough_behavior"></a> [integration\_passthrough\_behavior](#input\_integration\_passthrough\_behavior) | The integration passthrough behavior (WHEN\_NO\_MATCH, WHEN\_NO\_TEMPLATES, NEVER). Required if request\_templates is used. | `string` | `null` | no |
| <a name="input_integration_request_parameters"></a> [integration\_request\_parameters](#input\_integration\_request\_parameters) | A map of request query string parameters and headers that should be passed to the backend responder. For example: request\_parameters = { "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header" }. | `map(string)` | `null` | no |
| <a name="input_integration_request_templates"></a> [integration\_request\_templates](#input\_integration\_request\_templates) | A map of the integration's request templates. | `map(string)` | `null` | no |
| <a name="input_integration_response_content_handling"></a> [integration\_response\_content\_handling](#input\_integration\_response\_content\_handling) | Specifies how to handle request payload content type conversions. Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification. | `string` | `null` | no |
| <a name="input_integration_response_parameters"></a> [integration\_response\_parameters](#input\_integration\_response\_parameters) | A map of response parameters that can be read from the backend response. For example: response\_parameters = { "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }. | `map(string)` | `null` | no |
| <a name="input_integration_response_selection_pattern"></a> [integration\_response\_selection\_pattern](#input\_integration\_response\_selection\_pattern) | Specifies the regular expression pattern used to choose an integration response based on the response from the backend. | `string` | `null` | no |
| <a name="input_integration_response_templates"></a> [integration\_response\_templates](#input\_integration\_response\_templates) | A map specifying the templates used to transform the integration response body. | `map(string)` | `null` | no |
| <a name="input_integration_timeout_milliseconds"></a> [integration\_timeout\_milliseconds](#input\_integration\_timeout\_milliseconds) | Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds. | `number` | `29000` | no |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS\_PROXY (for Lambda proxy integration) and HTTP\_PROXY (for HTTP proxy integration). An HTTP or HTTP\_PROXY integration with a connection\_type of VPC\_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC. | `string` | `null` | no |
| <a name="input_integration_uri"></a> [integration\_uri](#input\_integration\_uri) | The input's URI. Required if type is AWS, AWS\_PROXY, HTTP or HTTP\_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service\|service}:{path\|action}/{service\_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations. | `string` | `null` | no |
| <a name="input_method_authorization_scopes"></a> [method\_authorization\_scopes](#input\_method\_authorization\_scopes) | The authorization scopes used when the authorization is COGNITO\_USER\_POOLS. | `list(string)` | `null` | no |
| <a name="input_method_http_method"></a> [method\_http\_method](#input\_method\_http\_method) | The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY). | `string` | `null` | no |
| <a name="input_method_operation_name"></a> [method\_operation\_name](#input\_method\_operation\_name) | The function name that will be given to the method when generating an SDK through API Gateway. | `string` | `null` | no |
| <a name="input_method_request_models"></a> [method\_request\_models](#input\_method\_request\_models) | A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws\_api\_gateway\_model's name. | `map(string)` | `null` | no |
| <a name="input_method_request_parameters"></a> [method\_request\_parameters](#input\_method\_request\_parameters) | A map of request query string parameters and headers that should be passed to the integration. For example: request\_parameters = {"method.request.header.X-Some-Header" = true "method.request.querystring.some-query-param" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request. | `map(string)` | `null` | no |
| <a name="input_method_request_validator_id"></a> [method\_request\_validator\_id](#input\_method\_request\_validator\_id) | The ID of a aws\_api\_gateway\_request\_validator | `string` | `null` | no |
| <a name="input_method_response_models"></a> [method\_response\_models](#input\_method\_response\_models) | A map of the API models used for the response's content type. | `map(string)` | `null` | no |
| <a name="input_method_response_parameters"></a> [method\_response\_parameters](#input\_method\_response\_parameters) | A map of response parameters that can be sent to the caller. For example: response\_parameters = { "method.response.header.X-Some-Header" = true } would define that the header X-Some-Header can be provided on the response. | `map(string)` | `null` | no |
| <a name="input_method_response_status_code"></a> [method\_response\_status\_code](#input\_method\_response\_status\_code) | The HTTP status code. | `string` | `null` | no |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The API resource ID | `string` | n/a | yes |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The ID of the associated REST API | `string` | n/a | yes |
| <a name="input_tls_config_insecure_skip_verification"></a> [tls\_config\_insecure\_skip\_verification](#input\_tls\_config\_insecure\_skip\_verification) | Specifies whether or not API Gateway skips verification that the certificate for an integration endpoint is issued by a supported certificate authority. Not recommended. | `string` | `null` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->