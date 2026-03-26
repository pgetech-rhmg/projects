# AWS Appsync Terraform module



 Terraform base module for deploying and managing Appsync modules () on Amazon Web Services (AWS). 



 Appsync Modules can be found at `appsync/modules/*`



 Appsync Modules examples can be found at `appsync/examples/*`
<!-- BEGIN_TF_DOCS -->
# AWS AppSync module
# Terraform module which creates graphql\_api
# As confirmed by PG&E only 'AWS\_IAM' & 'OPENID\_CONNECT' types are allowed

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appsync_graphql_api.graphql_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_graphql_api) | resource |
| [aws_wafv2_web_acl_association.graphql_api_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_authentication_provider"></a> [additional\_authentication\_provider](#input\_additional\_authentication\_provider) | One or more additional authentication providers for the GraphqlApi. | `list(any)` | `[]` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | Authentication type. Valid values: AWS\_IAM, AMAZON\_COGNITO\_USER\_POOLS, OPENID\_CONNECT, AWS\_LAMBDA. | `string` | n/a | yes |
| <a name="input_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#input\_cloudwatch\_logs\_role\_arn) | Amazon Resource Name of the service role that AWS AppSync will assume to publish to Amazon CloudWatch logs in your account. | `string` | n/a | yes |
| <a name="input_lambda_authorizer_config"></a> [lambda\_authorizer\_config](#input\_lambda\_authorizer\_config) | authorizer\_uri :<br> ARN of the Lambda function to be called for authorization. Note: This Lambda function must have a resource-based policy assigned to it, to allow lambda:InvokeFunction from service principal 'appsync.amazonaws.com'.<br>authorizer\_result\_ttl\_in\_seconds : <br> Number of seconds a response should be cached for. The default is 5 minutes (300 seconds). The Lambda function can override this by returning a ttlOverride key in its response. A value of 0 disables caching of responses. Minimum value of 0. Maximum value of 3600.<br> identity\_validation\_expression:<br>   Regular expression for validation of tokens before the Lambda function is called. | <pre>object({<br>    authorizer_uri                   = string<br>    authorizer_result_ttl_in_seconds = optional(number)<br>    identity_validation_expression   = optional(string)<br>  })</pre> | <pre>{<br>  "authorizer_result_ttl_in_seconds": null,<br>  "authorizer_uri": "",<br>  "identity_validation_expression": null<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | User-supplied name for the GraphqlApi. | `string` | n/a | yes |
| <a name="input_openid_connect_config"></a> [openid\_connect\_config](#input\_openid\_connect\_config) | issuer :<br> Issuer for the OpenID Connect configuration. The issuer returned by discovery MUST exactly match the value of issuer in the ID Token.<br>auth\_ttl : <br> Number of milliseconds a token is valid after being authenticated.<br> client\_id :<br>   Client identifier of the Relying party at the OpenID identity provider. This identifier is typically obtained when the Relying party is registered with the OpenID identity provider. You can specify a regular expression so the AWS AppSync can validate against multiple client identifiers at a time.<br> iat\_ttl :<br>   Number of milliseconds a token is valid after being issued to a user. | <pre>object({<br>    issuer    = string<br>    auth_ttl  = optional(number)<br>    client_id = optional(string)<br>    iat_ttl   = optional(number)<br><br>  })</pre> | <pre>{<br>  "auth_ttl": null,<br>  "client_id": null,<br>  "iat_ttl": null,<br>  "issuer": null<br>}</pre> | no |
| <a name="input_schema"></a> [schema](#input\_schema) | Schema definition, in GraphQL schema language format. Terraform cannot perform drift detection of this configuration. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |
| <a name="input_user_pool_config"></a> [user\_pool\_config](#input\_user\_pool\_config) | default\_action :<br> Action that you want your GraphQL API to take when a request that uses Amazon Cognito User Pool authentication doesn't match the Amazon Cognito User Pool configuration.<br>user\_pool\_id : <br> User pool ID.<br>app\_id\_client\_regex :<br>   Regular expression for validating the incoming Amazon Cognito User Pool app client ID.<br>aws\_region :<br>   AWS region in which the user pool was created. | <pre>object({<br>    default_action      = string<br>    user_pool_id        = string<br>    app_id_client_regex = optional(string)<br>    aws_region          = optional(string)<br>  })</pre> | <pre>{<br>  "app_id_client_regex": null,<br>  "aws_region": null,<br>  "default_action": null,<br>  "user_pool_id": null<br>}</pre> | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Sets the value of the GraphQL API to public (GLOBAL) or private (PRIVATE). Defaults to GLOBAL if not set. Cannot be changed once set. | `string` | `null` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource. | `string` | n/a | yes |
| <a name="input_xray_enabled"></a> [xray\_enabled](#input\_xray\_enabled) | Whether tracing with X-ray is enabled. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appsync_graphql_api_all"></a> [appsync\_graphql\_api\_all](#output\_appsync\_graphql\_api\_all) | Map of appsync\_graphql object. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN. |
| <a name="output_id"></a> [id](#output\_id) | API ID. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_uris"></a> [uris](#output\_uris) | Map of URIs associated with the APIE.g., uris[GRAPHQL] = https://ID.appsync-api.REGION.amazonaws.com/graphql. |


<!-- END_TF_DOCS -->