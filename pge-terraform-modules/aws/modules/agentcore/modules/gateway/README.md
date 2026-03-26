<!-- BEGIN_TF_DOCS -->
Primary entrypoint for the gateway submodule.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0 |

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagentcore_gateway_target.gateway_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_gateway_target) | resource |
| [aws_iam_role.gateway_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.gateway_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_permission.cross_account_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [awscc_bedrockagentcore_gateway.agent_gateway](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey_credential_provider_arn"></a> [apikey\_credential\_provider\_arn](#input\_apikey\_credential\_provider\_arn) | ARN of the API key credential provider created with CreateApiKeyCredentialProvider. Required when enable\_apikey\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_apikey_secret_arn"></a> [apikey\_secret\_arn](#input\_apikey\_secret\_arn) | ARN of the AWS Secrets Manager secret containing the API key. Required when enable\_apikey\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_create_gateway"></a> [create\_gateway](#input\_create\_gateway) | Whether or not to create an agent core gateway. | `bool` | `false` | no |
| <a name="input_create_gateway_target"></a> [create\_gateway\_target](#input\_create\_gateway\_target) | Whether or not to create a Bedrock agent core gateway target. | `bool` | `false` | no |
| <a name="input_enable_apikey_outbound_auth"></a> [enable\_apikey\_outbound\_auth](#input\_enable\_apikey\_outbound\_auth) | Whether to enable outbound authorization with an API key for the gateway. | `bool` | `false` | no |
| <a name="input_enable_oauth_outbound_auth"></a> [enable\_oauth\_outbound\_auth](#input\_enable\_oauth\_outbound\_auth) | Whether to enable outbound authorization with an OAuth client for the gateway. | `bool` | `false` | no |
| <a name="input_gateway_allow_create_permissions"></a> [gateway\_allow\_create\_permissions](#input\_gateway\_allow\_create\_permissions) | Whether to allow create permissions for the gateway. | `bool` | `true` | no |
| <a name="input_gateway_allow_update_delete_permissions"></a> [gateway\_allow\_update\_delete\_permissions](#input\_gateway\_allow\_update\_delete\_permissions) | Whether to allow update and delete permissions for the gateway. | `bool` | `false` | no |
| <a name="input_gateway_authorizer_configuration"></a> [gateway\_authorizer\_configuration](#input\_gateway\_authorizer\_configuration) | Authorizer configuration for the agent core gateway. | <pre>object({<br/>    custom_jwt_authorizer = object({<br/>      allowed_audience = optional(list(string))<br/>      allowed_clients  = optional(list(string))<br/>      discovery_url    = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_gateway_authorizer_type"></a> [gateway\_authorizer\_type](#input\_gateway\_authorizer\_type) | The authorizer type for the gateway. Valid values: AWS\_IAM, CUSTOM\_JWT. | `string` | `"CUSTOM_JWT"` | no |
| <a name="input_gateway_cross_account_lambda_permissions"></a> [gateway\_cross\_account\_lambda\_permissions](#input\_gateway\_cross\_account\_lambda\_permissions) | Configuration for cross-account Lambda function access. Required only if Lambda functions are in different AWS accounts. | <pre>list(object({<br/>    lambda_function_arn      = string<br/>    gateway_service_role_arn = string<br/>  }))</pre> | `[]` | no |
| <a name="input_gateway_description"></a> [gateway\_description](#input\_gateway\_description) | Description of the agent core gateway. | `string` | `null` | no |
| <a name="input_gateway_exception_level"></a> [gateway\_exception\_level](#input\_gateway\_exception\_level) | Exception level for the gateway. Valid values: PARTIAL, FULL. | `string` | `null` | no |
| <a name="input_gateway_kms_key_arn"></a> [gateway\_kms\_key\_arn](#input\_gateway\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the gateway. | `string` | `null` | no |
| <a name="input_gateway_lambda_function_arns"></a> [gateway\_lambda\_function\_arns](#input\_gateway\_lambda\_function\_arns) | List of Lambda function ARNs that the gateway service role should be able to invoke. Required when using Lambda targets. | `list(string)` | `[]` | no |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | The name of the agent core gateway. | `string` | `"TerraformBedrockAgentCoreGateway"` | no |
| <a name="input_gateway_protocol_configuration"></a> [gateway\_protocol\_configuration](#input\_gateway\_protocol\_configuration) | Protocol configuration for the agent core gateway. | <pre>object({<br/>    mcp = object({<br/>      instructions       = optional(string)<br/>      search_type        = optional(string)<br/>      supported_versions = optional(list(string))<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_gateway_protocol_type"></a> [gateway\_protocol\_type](#input\_gateway\_protocol\_type) | The protocol type for the gateway. Valid value: MCP. | `string` | `"MCP"` | no |
| <a name="input_gateway_role_arn"></a> [gateway\_role\_arn](#input\_gateway\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core gateway. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_gateway_tags"></a> [gateway\_tags](#input\_gateway\_tags) | A map of tag keys and values for the agent core gateway. | `map(string)` | `null` | no |
| <a name="input_gateway_target_api_key_config"></a> [gateway\_target\_api\_key\_config](#input\_gateway\_target\_api\_key\_config) | Configuration for API key authentication for the gateway target. | <pre>object({<br/>    provider_arn              = string<br/>    credential_location       = optional(string)<br/>    credential_parameter_name = optional(string)<br/>    credential_prefix         = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_gateway_target_credential_provider_type"></a> [gateway\_target\_credential\_provider\_type](#input\_gateway\_target\_credential\_provider\_type) | Type of credential provider to use for the gateway target. Valid values: GATEWAY\_IAM\_ROLE, API\_KEY, OAUTH. | `string` | `"GATEWAY_IAM_ROLE"` | no |
| <a name="input_gateway_target_description"></a> [gateway\_target\_description](#input\_gateway\_target\_description) | Description of the gateway target. | `string` | `null` | no |
| <a name="input_gateway_target_gateway_id"></a> [gateway\_target\_gateway\_id](#input\_gateway\_target\_gateway\_id) | Identifier of the gateway that this target belongs to. If not provided, it will use the ID of the gateway created by this module. | `string` | `null` | no |
| <a name="input_gateway_target_lambda_config"></a> [gateway\_target\_lambda\_config](#input\_gateway\_target\_lambda\_config) | Configuration for Lambda function target. | <pre>object({<br/>    lambda_arn       = string<br/>    tool_schema_type = string # INLINE or S3<br/>    inline_schema = optional(object({<br/>      name        = string<br/>      description = string<br/>      input_schema = object({<br/>        type        = string<br/>        description = optional(string)<br/>        properties = optional(list(object({<br/>          name        = string<br/>          type        = string<br/>          description = optional(string)<br/>          required    = optional(bool, false)<br/>          nested_properties = optional(list(object({<br/>            name        = string<br/>            type        = string<br/>            description = optional(string)<br/>            required    = optional(bool)<br/>          })))<br/>          items = optional(object({<br/>            type        = string<br/>            description = optional(string)<br/>          }))<br/>        })))<br/>        items = optional(object({<br/>          type        = string<br/>          description = optional(string)<br/>        }))<br/>      })<br/>      output_schema = optional(object({<br/>        type        = string<br/>        description = optional(string)<br/>        properties = optional(list(object({<br/>          name        = string<br/>          type        = string<br/>          description = optional(string)<br/>          required    = optional(bool)<br/>        })))<br/>        items = optional(object({<br/>          type        = string<br/>          description = optional(string)<br/>        }))<br/>      }))<br/>    }))<br/>    s3_schema = optional(object({<br/>      uri                     = string<br/>      bucket_owner_account_id = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_gateway_target_mcp_server_config"></a> [gateway\_target\_mcp\_server\_config](#input\_gateway\_target\_mcp\_server\_config) | Configuration for MCP server target. | <pre>object({<br/>    endpoint = string<br/>  })</pre> | `null` | no |
| <a name="input_gateway_target_name"></a> [gateway\_target\_name](#input\_gateway\_target\_name) | The name of the gateway target. | `string` | `"TerraformBedrockAgentCoreGatewayTarget"` | no |
| <a name="input_gateway_target_oauth_config"></a> [gateway\_target\_oauth\_config](#input\_gateway\_target\_oauth\_config) | Configuration for OAuth authentication for the gateway target. | <pre>object({<br/>    provider_arn      = string<br/>    scopes            = optional(list(string))<br/>    custom_parameters = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_gateway_target_type"></a> [gateway\_target\_type](#input\_gateway\_target\_type) | Type of target to create. Valid values: LAMBDA, MCP\_SERVER. | `string` | `"LAMBDA"` | no |
| <a name="input_oauth_credential_provider_arn"></a> [oauth\_credential\_provider\_arn](#input\_oauth\_credential\_provider\_arn) | ARN of the OAuth credential provider created with CreateOauth2CredentialProvider. Required when enable\_oauth\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_oauth_secret_arn"></a> [oauth\_secret\_arn](#input\_oauth\_secret\_arn) | ARN of the AWS Secrets Manager secret containing the OAuth client credentials. Required when enable\_oauth\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_gateway_arn"></a> [agent\_gateway\_arn](#output\_agent\_gateway\_arn) | ARN of the created Bedrock AgentCore Gateway |
| <a name="output_agent_gateway_id"></a> [agent\_gateway\_id](#output\_agent\_gateway\_id) | ID of the created Bedrock AgentCore Gateway |
| <a name="output_agent_gateway_status"></a> [agent\_gateway\_status](#output\_agent\_gateway\_status) | Status of the created Bedrock AgentCore Gateway |
| <a name="output_agent_gateway_status_reasons"></a> [agent\_gateway\_status\_reasons](#output\_agent\_gateway\_status\_reasons) | Status reasons of the created Bedrock AgentCore Gateway |
| <a name="output_agent_gateway_url"></a> [agent\_gateway\_url](#output\_agent\_gateway\_url) | URL of the created Bedrock AgentCore Gateway |
| <a name="output_agent_gateway_workload_identity_details"></a> [agent\_gateway\_workload\_identity\_details](#output\_agent\_gateway\_workload\_identity\_details) | Workload identity details of the created Bedrock AgentCore Gateway |
| <a name="output_gateway_role_arn"></a> [gateway\_role\_arn](#output\_gateway\_role\_arn) | ARN of the IAM role created for the Bedrock AgentCore Gateway |
| <a name="output_gateway_role_name"></a> [gateway\_role\_name](#output\_gateway\_role\_name) | Name of the IAM role created for the Bedrock AgentCore Gateway |

<!-- END_TF_DOCS -->