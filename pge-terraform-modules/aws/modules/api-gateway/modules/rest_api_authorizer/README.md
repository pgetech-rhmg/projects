<!-- BEGIN_TF_DOCS -->
# AWS API Gateway Authorizer
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
| [aws_api_gateway_authorizer.api_gateway_authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorizer_credentials"></a> [authorizer\_credentials](#input\_authorizer\_credentials) | The credentials required for the authorizer. To specify an IAM Role for API Gateway to assume, use the IAM Role ARN. | `string` | `null` | no |
| <a name="input_authorizer_identity_source"></a> [authorizer\_identity\_source](#input\_authorizer\_identity\_source) | The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. "method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName". | `string` | `"method.request.header.Authorization"` | no |
| <a name="input_authorizer_identity_validation_expression"></a> [authorizer\_identity\_validation\_expression](#input\_authorizer\_identity\_validation\_expression) | A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response. | `string` | `null` | no |
| <a name="input_authorizer_name"></a> [authorizer\_name](#input\_authorizer\_name) | The name of the authorizer. | `string` | n/a | yes |
| <a name="input_authorizer_provider_arns"></a> [authorizer\_provider\_arns](#input\_authorizer\_provider\_arns) | required for type COGNITO\_USER\_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account\_id}:userpool/{user\_pool\_id}. | `list(string)` | `null` | no |
| <a name="input_authorizer_result_ttl_in_seconds"></a> [authorizer\_result\_ttl\_in\_seconds](#input\_authorizer\_result\_ttl\_in\_seconds) | The TTL of cached authorizer results in seconds. Defaults to 300. | `number` | `300` | no |
| <a name="input_authorizer_type"></a> [authorizer\_type](#input\_authorizer\_type) | The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO\_USER\_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN. | `string` | `"TOKEN"` | no |
| <a name="input_authorizer_uri"></a> [authorizer\_uri](#input\_authorizer\_uri) | The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service\_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations. | `string` | `null` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | The ID of the associated REST API | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_authorizer_id"></a> [api\_gateway\_authorizer\_id](#output\_api\_gateway\_authorizer\_id) | The ID for API Gateway Authorizer |

<!-- END_TF_DOCS -->