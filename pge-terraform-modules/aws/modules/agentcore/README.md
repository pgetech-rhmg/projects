<!-- BEGIN_TF_DOCS -->
AWS Bedrock AgentCore Module

## Overview

Terraform module for deploying **AWS Bedrock Agent Core** infrastructure to build, run, and scale AI-powered agents with custom runtimes, memory management, and gateway integrations.

This module provisions the complete infrastructure stack for Amazon Bedrock Agent Core, enabling you to:

- Deploy Custom Agent Runtimes - Container or code-based runtimes with VPC isolation
- Configure Agent Memory - DynamoDB-backed persistent memory with configurable retention policies
- Set Up Gateway Targets - API Gateway integrations for agent endpoints
- Enable Agent Tools - Browser automation and code interpreter capabilities
- Manage Workload Identity - IAM role federation for secure agent execution

## Key Features

- Multi-Framework Support: Compatible with LangChain, CrewAI, AutoGPT, Haystack, and custom frameworks
- Flexible Runtime Options: Container-based (ECR) or code-based (Lambda) runtime deployment
- VPC Integration: Secure agent runtime execution within your VPC with configurable security groups
- Memory Management: Configurable memory strategies (session-based, entity-based, user-based)
- Built-in CI/CD: Automated build and deployment pipelines with WIZ security scanning
- Production-Ready: KMS encryption, tagging standards, and PGE compliance built-in

## Documentation

- Wiki: [Bedrock AgentCore Documentation](https://wiki.comp.pge.com/display/CCE/AWS+Bedrock+AgentCore)
- Examples: Complete working examples in `examples/agent_runtime/`
- Encryption: [Terraform Modules and KMS](https://wiki.comp.pge.com/display/CCE/Terraform+Modules+and+KMS)

## Quick Start

```hcl
module "bedrock_agent" {
  source  = "app.terraform.io/pgetech/agentcore/aws"
  version = "~> 0.1.0"

  # Runtime Configuration
  create_runtime        = true
  runtime_name          = "my-ai-agent-runtime"
  runtime_container_uri = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-agent:latest"

  runtime_network_configuration = {
    security_groups = ["sg-12345678"]
    subnets         = ["subnet-abc123", "subnet-def456"]
  }

  # Memory Configuration
  create_memory = true
  memory_name   = "my-agent-memory"
  memory_type   = "DYNAMODB"

  # Agent Configuration
  create_agent      = true
  agent_name        = "my-ai-agent"
  agent_instruction = "You are a helpful AI assistant"
}
```

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/Terraform+Modules+and+KMS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.24.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

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
| [aws_iam_role.runtime_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.runtime_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.runtime_slr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [awscc_bedrockagentcore_runtime.agent_runtime_code](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_runtime) | resource |
| [awscc_bedrockagentcore_runtime.agent_runtime_container](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_runtime) | resource |
| [awscc_bedrockagentcore_runtime_endpoint.agent_runtime_endpoint](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_runtime_endpoint) | resource |
| [awscc_bedrockagentcore_workload_identity.workload_identity](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_workload_identity) | resource |
| [random_string.solution_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.iam_role_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey_credential_provider_arn"></a> [apikey\_credential\_provider\_arn](#input\_apikey\_credential\_provider\_arn) | ARN of the API key credential provider created with CreateApiKeyCredentialProvider. Required when enable\_apikey\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_apikey_secret_arn"></a> [apikey\_secret\_arn](#input\_apikey\_secret\_arn) | ARN of the AWS Secrets Manager secret containing the API key. Required when enable\_apikey\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_browser_description"></a> [browser\_description](#input\_browser\_description) | Description of the agent core browser. | `string` | `null` | no |
| <a name="input_browser_name"></a> [browser\_name](#input\_browser\_name) | The name of the agent core browser. Valid characters are a-z, A-Z, 0-9, \_ (underscore). The name must start with a letter and can be up to 48 characters long. | `string` | `"TerraformBedrockAgentCoreBrowser"` | no |
| <a name="input_browser_network_configuration"></a> [browser\_network\_configuration](#input\_browser\_network\_configuration) | VPC network configuration for the agent core browser. Required when browser\_network\_mode is set to 'VPC'. | <pre>object({<br/>    security_groups = optional(list(string))<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_browser_network_mode"></a> [browser\_network\_mode](#input\_browser\_network\_mode) | Network mode configuration type for the agent core browser. Valid values: PUBLIC, VPC. | `string` | `"PUBLIC"` | no |
| <a name="input_browser_recording_config"></a> [browser\_recording\_config](#input\_browser\_recording\_config) | Configuration for browser session recording when enabled. Bucket name must follow S3 naming conventions (lowercase alphanumeric characters, dots, and hyphens), between 3 and 63 characters, starting and ending with alphanumeric character. | <pre>object({<br/>    bucket = string<br/>    prefix = string<br/>  })</pre> | `null` | no |
| <a name="input_browser_recording_enabled"></a> [browser\_recording\_enabled](#input\_browser\_recording\_enabled) | Whether to enable browser session recording to S3. | `bool` | `false` | no |
| <a name="input_browser_role_arn"></a> [browser\_role\_arn](#input\_browser\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core browser. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_browser_tags"></a> [browser\_tags](#input\_browser\_tags) | A map of tag keys and values for the agent core browser. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: \_ . : / = + @ - | `map(string)` | `null` | no |
| <a name="input_code_interpreter_description"></a> [code\_interpreter\_description](#input\_code\_interpreter\_description) | Description of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, \_ (underscore), - (hyphen) and spaces. The description can have up to 200 characters. | `string` | `null` | no |
| <a name="input_code_interpreter_name"></a> [code\_interpreter\_name](#input\_code\_interpreter\_name) | The name of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, \_ (underscore). The name must start with a letter and can be up to 48 characters long. | `string` | `"TerraformBedrockAgentCoreCodeInterpreter"` | no |
| <a name="input_code_interpreter_network_configuration"></a> [code\_interpreter\_network\_configuration](#input\_code\_interpreter\_network\_configuration) | VPC network configuration for the agent core code interpreter. | <pre>object({<br/>    security_groups = optional(list(string))<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_code_interpreter_network_mode"></a> [code\_interpreter\_network\_mode](#input\_code\_interpreter\_network\_mode) | Network mode configuration type for the agent core code interpreter. Valid values: SANDBOX, VPC. | `string` | `"SANDBOX"` | no |
| <a name="input_code_interpreter_role_arn"></a> [code\_interpreter\_role\_arn](#input\_code\_interpreter\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core code interpreter. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_code_interpreter_tags"></a> [code\_interpreter\_tags](#input\_code\_interpreter\_tags) | A map of tag keys and values for the agent core code interpreter. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: \_ . : / = + @ - | `map(string)` | `null` | no |
| <a name="input_create_browser"></a> [create\_browser](#input\_create\_browser) | Whether or not to create an agent core browser custom. | `bool` | `false` | no |
| <a name="input_create_code_interpreter"></a> [create\_code\_interpreter](#input\_create\_code\_interpreter) | Whether or not to create an agent core code interpreter custom. | `bool` | `false` | no |
| <a name="input_create_gateway"></a> [create\_gateway](#input\_create\_gateway) | Whether or not to create an agent core gateway. | `bool` | `false` | no |
| <a name="input_create_gateway_target"></a> [create\_gateway\_target](#input\_create\_gateway\_target) | Whether or not to create a Bedrock agent core gateway target. | `bool` | `false` | no |
| <a name="input_create_memory"></a> [create\_memory](#input\_create\_memory) | Whether or not to create an agent core memory. | `bool` | `false` | no |
| <a name="input_create_runtime"></a> [create\_runtime](#input\_create\_runtime) | Whether or not to create an agent core runtime. | `bool` | `false` | no |
| <a name="input_create_runtime_endpoint"></a> [create\_runtime\_endpoint](#input\_create\_runtime\_endpoint) | Whether or not to create an agent core runtime endpoint. | `bool` | `false` | no |
| <a name="input_create_workload_identity"></a> [create\_workload\_identity](#input\_create\_workload\_identity) | Whether or not to create a Bedrock agent core workload identity. | `bool` | `false` | no |
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
| <a name="input_memory_description"></a> [memory\_description](#input\_memory\_description) | Description of the agent core memory. | `string` | `null` | no |
| <a name="input_memory_encryption_key_arn"></a> [memory\_encryption\_key\_arn](#input\_memory\_encryption\_key\_arn) | The ARN of the KMS key used to encrypt the memory. | `string` | `null` | no |
| <a name="input_memory_event_expiry_duration"></a> [memory\_event\_expiry\_duration](#input\_memory\_event\_expiry\_duration) | Duration in days until memory events expire. | `number` | `90` | no |
| <a name="input_memory_execution_role_arn"></a> [memory\_execution\_role\_arn](#input\_memory\_execution\_role\_arn) | Optional IAM role ARN for the Bedrock agent core memory. | `string` | `null` | no |
| <a name="input_memory_name"></a> [memory\_name](#input\_memory\_name) | The name of the agent core memory. | `string` | `"TerraformBedrockAgentCoreMemory"` | no |
| <a name="input_memory_strategies"></a> [memory\_strategies](#input\_memory\_strategies) | List of memory strategies attached to this memory. | <pre>list(object({<br/>    semantic_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    summary_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    user_preference_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    custom_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>      configuration = optional(object({<br/>        self_managed_configuration = optional(object({<br/>          historical_context_window_size = optional(number, 4) # Default to 4 messages<br/>          invocation_configuration = object({<br/>            # Both fields are required when a self-managed configuration is used<br/>            payload_delivery_bucket_name = string<br/>            topic_arn                    = string<br/>          })<br/>          trigger_conditions = optional(list(object({<br/>            message_based_trigger = optional(object({<br/>              message_count = optional(number, 1) # Default to 1 message<br/>            }))<br/>            time_based_trigger = optional(object({<br/>              idle_session_timeout = optional(number, 10) # Default to 10 seconds<br/>            }))<br/>            token_based_trigger = optional(object({<br/>              token_count = optional(number, 100) # Default to 100 tokens<br/>            }))<br/>          })))<br/>        }))<br/>        semantic_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>          extraction = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>        summary_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>        user_preference_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>          extraction = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_memory_tags"></a> [memory\_tags](#input\_memory\_tags) | A map of tag keys and values for the agent core memory. | `map(string)` | `null` | no |
| <a name="input_oauth_credential_provider_arn"></a> [oauth\_credential\_provider\_arn](#input\_oauth\_credential\_provider\_arn) | ARN of the OAuth credential provider created with CreateOauth2CredentialProvider. Required when enable\_oauth\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_oauth_secret_arn"></a> [oauth\_secret\_arn](#input\_oauth\_secret\_arn) | ARN of the AWS Secrets Manager secret containing the OAuth client credentials. Required when enable\_oauth\_outbound\_auth is true. | `string` | `null` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no |
| <a name="input_runtime_artifact_type"></a> [runtime\_artifact\_type](#input\_runtime\_artifact\_type) | The type of artifact to use for the agent core runtime. Valid values: container, code. | `string` | `"container"` | no |
| <a name="input_runtime_authorizer_configuration"></a> [runtime\_authorizer\_configuration](#input\_runtime\_authorizer\_configuration) | Authorizer configuration for the agent core runtime. | <pre>object({<br/>    custom_jwt_authorizer = object({<br/>      allowed_audience = optional(list(string))<br/>      allowed_clients  = optional(list(string))<br/>      discovery_url    = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_runtime_code_entry_point"></a> [runtime\_code\_entry\_point](#input\_runtime\_code\_entry\_point) | Entry point for the code runtime. Required when runtime\_artifact\_type is set to 'code'. | `list(string)` | `null` | no |
| <a name="input_runtime_code_runtime_type"></a> [runtime\_code\_runtime\_type](#input\_runtime\_code\_runtime\_type) | Runtime type for the code. Required when runtime\_artifact\_type is set to 'code'. Valid values: PYTHON\_3\_10, PYTHON\_3\_11, PYTHON\_3\_12, PYTHON\_3\_13 | `string` | `null` | no |
| <a name="input_runtime_code_s3_bucket"></a> [runtime\_code\_s3\_bucket](#input\_runtime\_code\_s3\_bucket) | S3 bucket containing the code package for the agent core runtime. Required when runtime\_artifact\_type is set to 'code'. | `string` | `null` | no |
| <a name="input_runtime_code_s3_prefix"></a> [runtime\_code\_s3\_prefix](#input\_runtime\_code\_s3\_prefix) | S3 prefix (key) for the code package. Required when runtime\_artifact\_type is set to 'code'. | `string` | `null` | no |
| <a name="input_runtime_code_s3_version_id"></a> [runtime\_code\_s3\_version\_id](#input\_runtime\_code\_s3\_version\_id) | S3 version ID of the code package. Optional when runtime\_artifact\_type is set to 'code'. | `string` | `null` | no |
| <a name="input_runtime_container_uri"></a> [runtime\_container\_uri](#input\_runtime\_container\_uri) | The ECR URI of the container for the agent core runtime. Required when runtime\_artifact\_type is set to 'container'. | `string` | `null` | no |
| <a name="input_runtime_description"></a> [runtime\_description](#input\_runtime\_description) | Description of the agent runtime. | `string` | `null` | no |
| <a name="input_runtime_endpoint_agent_runtime_id"></a> [runtime\_endpoint\_agent\_runtime\_id](#input\_runtime\_endpoint\_agent\_runtime\_id) | The ID of the agent core runtime associated with the endpoint. If not provided, it will use the ID of the agent runtime created by this module. | `string` | `null` | no |
| <a name="input_runtime_endpoint_description"></a> [runtime\_endpoint\_description](#input\_runtime\_endpoint\_description) | Description of the agent core runtime endpoint. | `string` | `null` | no |
| <a name="input_runtime_endpoint_name"></a> [runtime\_endpoint\_name](#input\_runtime\_endpoint\_name) | The name of the agent core runtime endpoint. | `string` | `"TerraformBedrockAgentCoreRuntimeEndpoint"` | no |
| <a name="input_runtime_endpoint_tags"></a> [runtime\_endpoint\_tags](#input\_runtime\_endpoint\_tags) | A map of tag keys and values for the agent core runtime endpoint. | `map(string)` | `null` | no |
| <a name="input_runtime_environment_variables"></a> [runtime\_environment\_variables](#input\_runtime\_environment\_variables) | Environment variables for the agent core runtime. | `map(string)` | `null` | no |
| <a name="input_runtime_lifecycle_configuration"></a> [runtime\_lifecycle\_configuration](#input\_runtime\_lifecycle\_configuration) | Lifecycle configuration for managing runtime sessions. | <pre>object({<br/>    idle_runtime_session_timeout = optional(number)<br/>    max_lifetime                 = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | The name of the agent core runtime. | `string` | `"TerraformBedrockAgentCoreRuntime"` | no |
| <a name="input_runtime_network_configuration"></a> [runtime\_network\_configuration](#input\_runtime\_network\_configuration) | VPC network configuration for the agent core runtime. | <pre>object({<br/>    security_groups = optional(list(string))<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_runtime_network_mode"></a> [runtime\_network\_mode](#input\_runtime\_network\_mode) | Network mode configuration type for the agent core runtime. Valid values: PUBLIC, VPC. | `string` | `"PUBLIC"` | no |
| <a name="input_runtime_protocol_configuration"></a> [runtime\_protocol\_configuration](#input\_runtime\_protocol\_configuration) | Protocol configuration for the agent core runtime. | `string` | `null` | no |
| <a name="input_runtime_request_header_configuration"></a> [runtime\_request\_header\_configuration](#input\_runtime\_request\_header\_configuration) | Configuration for HTTP request headers. | <pre>object({<br/>    request_header_allowlist = optional(set(string))<br/>  })</pre> | `null` | no |
| <a name="input_runtime_role_arn"></a> [runtime\_role\_arn](#input\_runtime\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core runtime. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_runtime_tags"></a> [runtime\_tags](#input\_runtime\_tags) | A map of tag keys and values for the agent core runtime. | `map(string)` | `null` | no |
| <a name="input_user_pool_admin_email"></a> [user\_pool\_admin\_email](#input\_user\_pool\_admin\_email) | Email address for the admin user. | `string` | `"admin@example.com"` | no |
| <a name="input_user_pool_allowed_clients"></a> [user\_pool\_allowed\_clients](#input\_user\_pool\_allowed\_clients) | List of allowed clients for the Cognito User Pool JWT authorizer. | `list(string)` | `[]` | no |
| <a name="input_user_pool_callback_urls"></a> [user\_pool\_callback\_urls](#input\_user\_pool\_callback\_urls) | List of allowed callback URLs for the Cognito User Pool client. | `list(string)` | <pre>[<br/>  "http://localhost:3000"<br/>]</pre> | no |
| <a name="input_user_pool_create_admin"></a> [user\_pool\_create\_admin](#input\_user\_pool\_create\_admin) | Whether to create an admin user in the Cognito User Pool. | `bool` | `false` | no |
| <a name="input_user_pool_logout_urls"></a> [user\_pool\_logout\_urls](#input\_user\_pool\_logout\_urls) | List of allowed logout URLs for the Cognito User Pool client. | `list(string)` | <pre>[<br/>  "http://localhost:3000"<br/>]</pre> | no |
| <a name="input_user_pool_mfa_configuration"></a> [user\_pool\_mfa\_configuration](#input\_user\_pool\_mfa\_configuration) | MFA configuration for the Cognito User Pool. Valid values: OFF, OPTIONAL, REQUIRED. | `string` | `"OFF"` | no |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | The name of the Cognito User Pool to create when JWT auth info is not provided. | `string` | `"AgentCoreUserPool"` | no |
| <a name="input_user_pool_password_policy"></a> [user\_pool\_password\_policy](#input\_user\_pool\_password\_policy) | Password policy for the Cognito User Pool. | <pre>object({<br/>    minimum_length    = optional(number, 8)<br/>    require_lowercase = optional(bool, true)<br/>    require_numbers   = optional(bool, true)<br/>    require_symbols   = optional(bool, true)<br/>    require_uppercase = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_user_pool_refresh_token_validity_days"></a> [user\_pool\_refresh\_token\_validity\_days](#input\_user\_pool\_refresh\_token\_validity\_days) | Number of days that refresh tokens are valid for. | `number` | `30` | no |
| <a name="input_user_pool_tags"></a> [user\_pool\_tags](#input\_user\_pool\_tags) | A map of tag keys and values for the Cognito User Pool. | `map(string)` | `null` | no |
| <a name="input_user_pool_token_validity_hours"></a> [user\_pool\_token\_validity\_hours](#input\_user\_pool\_token\_validity\_hours) | Number of hours that ID and access tokens are valid for. | `number` | `24` | no |
| <a name="input_workload_identity_allowed_resource_oauth_2_return_urls"></a> [workload\_identity\_allowed\_resource\_oauth\_2\_return\_urls](#input\_workload\_identity\_allowed\_resource\_oauth\_2\_return\_urls) | The list of allowed OAuth2 return URLs for resources associated with this workload identity. | `list(string)` | `null` | no |
| <a name="input_workload_identity_name"></a> [workload\_identity\_name](#input\_workload\_identity\_name) | The name of the workload identity. | `string` | `"TerraformBedrockAgentCoreWorkloadIdentity"` | no |
| <a name="input_workload_identity_tags"></a> [workload\_identity\_tags](#input\_workload\_identity\_tags) | A map of tag keys and values for the workload identity. | `map(string)` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_runtime_arn"></a> [agent\_runtime\_arn](#output\_agent\_runtime\_arn) | ARN of the created Bedrock AgentCore Runtime |
| <a name="output_agent_runtime_endpoint_arn"></a> [agent\_runtime\_endpoint\_arn](#output\_agent\_runtime\_endpoint\_arn) | ARN of the created Bedrock AgentCore Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_id"></a> [agent\_runtime\_endpoint\_id](#output\_agent\_runtime\_endpoint\_id) | ID of the created Bedrock AgentCore Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_live_version"></a> [agent\_runtime\_endpoint\_live\_version](#output\_agent\_runtime\_endpoint\_live\_version) | Live version of the created Bedrock AgentCore Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_status"></a> [agent\_runtime\_endpoint\_status](#output\_agent\_runtime\_endpoint\_status) | Status of the created Bedrock AgentCore Runtime Endpoint |
| <a name="output_agent_runtime_endpoint_target_version"></a> [agent\_runtime\_endpoint\_target\_version](#output\_agent\_runtime\_endpoint\_target\_version) | Target version of the created Bedrock AgentCore Runtime Endpoint |
| <a name="output_agent_runtime_id"></a> [agent\_runtime\_id](#output\_agent\_runtime\_id) | ID of the created Bedrock AgentCore Runtime |
| <a name="output_agent_runtime_status"></a> [agent\_runtime\_status](#output\_agent\_runtime\_status) | Status of the created Bedrock AgentCore Runtime |
| <a name="output_agent_runtime_version"></a> [agent\_runtime\_version](#output\_agent\_runtime\_version) | Version of the created Bedrock AgentCore Runtime |
| <a name="output_agent_runtime_workload_identity_details"></a> [agent\_runtime\_workload\_identity\_details](#output\_agent\_runtime\_workload\_identity\_details) | Workload identity details of the created Bedrock AgentCore Runtime |
| <a name="output_runtime_role_arn"></a> [runtime\_role\_arn](#output\_runtime\_role\_arn) | ARN of the IAM role created for the Bedrock AgentCore Runtime |
| <a name="output_runtime_role_name"></a> [runtime\_role\_name](#output\_runtime\_role\_name) | Name of the IAM role created for the Bedrock AgentCore Runtime |
| <a name="output_workload_identity_arn"></a> [workload\_identity\_arn](#output\_workload\_identity\_arn) | ARN of the created Bedrock AgentCore Workload Identity |
| <a name="output_workload_identity_created_time"></a> [workload\_identity\_created\_time](#output\_workload\_identity\_created\_time) | Creation timestamp of the created Bedrock AgentCore Workload Identity |
| <a name="output_workload_identity_id"></a> [workload\_identity\_id](#output\_workload\_identity\_id) | ID of the created Bedrock AgentCore Workload Identity |
| <a name="output_workload_identity_last_updated_time"></a> [workload\_identity\_last\_updated\_time](#output\_workload\_identity\_last\_updated\_time) | Last update timestamp of the created Bedrock AgentCore Workload Identity |

<!-- END_TF_DOCS -->