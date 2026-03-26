<!-- BEGIN_TF_DOCS -->
Primary entrypoint for the browser submodule.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

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
| [aws_iam_role.browser_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.browser_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [awscc_bedrockagentcore_browser_custom.agent_browser](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_browser_custom) | resource |
| [time_sleep.browser_iam_role_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_browser_description"></a> [browser\_description](#input\_browser\_description) | Description of the agent core browser. | `string` | `null` | no |
| <a name="input_browser_name"></a> [browser\_name](#input\_browser\_name) | The name of the agent core browser. Valid characters are a-z, A-Z, 0-9, \_ (underscore). The name must start with a letter and can be up to 48 characters long. | `string` | `"TerraformBedrockAgentCoreBrowser"` | no |
| <a name="input_browser_network_configuration"></a> [browser\_network\_configuration](#input\_browser\_network\_configuration) | VPC network configuration for the agent core browser. Required when browser\_network\_mode is set to 'VPC'. | <pre>object({<br/>    security_groups = optional(list(string))<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_browser_network_mode"></a> [browser\_network\_mode](#input\_browser\_network\_mode) | Network mode configuration type for the agent core browser. Valid values: PUBLIC, VPC. | `string` | `"PUBLIC"` | no |
| <a name="input_browser_recording_config"></a> [browser\_recording\_config](#input\_browser\_recording\_config) | Configuration for browser session recording when enabled. Bucket name must follow S3 naming conventions (lowercase alphanumeric characters, dots, and hyphens), between 3 and 63 characters, starting and ending with alphanumeric character. | <pre>object({<br/>    bucket = string<br/>    prefix = string<br/>  })</pre> | `null` | no |
| <a name="input_browser_recording_enabled"></a> [browser\_recording\_enabled](#input\_browser\_recording\_enabled) | Whether to enable browser session recording to S3. | `bool` | `false` | no |
| <a name="input_browser_role_arn"></a> [browser\_role\_arn](#input\_browser\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core browser. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_browser_tags"></a> [browser\_tags](#input\_browser\_tags) | A map of tag keys and values for the agent core browser. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: \_ . : / = + @ - | `map(string)` | `null` | no |
| <a name="input_create_browser"></a> [create\_browser](#input\_create\_browser) | Whether or not to create an agent core browser custom. | `bool` | `false` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_browser_arn"></a> [agent\_browser\_arn](#output\_agent\_browser\_arn) | ARN of the created Bedrock AgentCore Browser Custom |
| <a name="output_agent_browser_created_at"></a> [agent\_browser\_created\_at](#output\_agent\_browser\_created\_at) | Creation timestamp of the created Bedrock AgentCore Browser Custom |
| <a name="output_agent_browser_failure_reason"></a> [agent\_browser\_failure\_reason](#output\_agent\_browser\_failure\_reason) | Failure reason if the Bedrock AgentCore Browser Custom failed |
| <a name="output_agent_browser_id"></a> [agent\_browser\_id](#output\_agent\_browser\_id) | ID of the created Bedrock AgentCore Browser Custom |
| <a name="output_agent_browser_last_updated_at"></a> [agent\_browser\_last\_updated\_at](#output\_agent\_browser\_last\_updated\_at) | Last update timestamp of the created Bedrock AgentCore Browser Custom |
| <a name="output_agent_browser_status"></a> [agent\_browser\_status](#output\_agent\_browser\_status) | Status of the created Bedrock AgentCore Browser Custom |
| <a name="output_browser_admin_permissions"></a> [browser\_admin\_permissions](#output\_browser\_admin\_permissions) | IAM permissions for browser administration operations |
| <a name="output_browser_admin_policy"></a> [browser\_admin\_policy](#output\_browser\_admin\_policy) | Policy document for browser administration |
| <a name="output_browser_full_access_permissions"></a> [browser\_full\_access\_permissions](#output\_browser\_full\_access\_permissions) | Full access IAM permissions for all browser operations |
| <a name="output_browser_full_access_policy"></a> [browser\_full\_access\_policy](#output\_browser\_full\_access\_policy) | Policy document for granting full access to Bedrock AgentCore Browser operations |
| <a name="output_browser_list_permissions"></a> [browser\_list\_permissions](#output\_browser\_list\_permissions) | IAM permissions for listing browser resources |
| <a name="output_browser_list_policy"></a> [browser\_list\_policy](#output\_browser\_list\_policy) | Policy document for listing browser resources |
| <a name="output_browser_read_permissions"></a> [browser\_read\_permissions](#output\_browser\_read\_permissions) | IAM permissions for reading browser information |
| <a name="output_browser_read_policy"></a> [browser\_read\_policy](#output\_browser\_read\_policy) | Policy document for reading browser information |
| <a name="output_browser_role_arn"></a> [browser\_role\_arn](#output\_browser\_role\_arn) | ARN of the IAM role created for the Bedrock AgentCore Browser Custom |
| <a name="output_browser_role_name"></a> [browser\_role\_name](#output\_browser\_role\_name) | Name of the IAM role created for the Bedrock AgentCore Browser Custom |
| <a name="output_browser_session_permissions"></a> [browser\_session\_permissions](#output\_browser\_session\_permissions) | IAM permissions for managing browser sessions |
| <a name="output_browser_session_policy"></a> [browser\_session\_policy](#output\_browser\_session\_policy) | Policy document for browser session management |
| <a name="output_browser_stream_permissions"></a> [browser\_stream\_permissions](#output\_browser\_stream\_permissions) | IAM permissions for browser streaming operations |
| <a name="output_browser_stream_policy"></a> [browser\_stream\_policy](#output\_browser\_stream\_policy) | Policy document for browser streaming operations |
| <a name="output_browser_use_permissions"></a> [browser\_use\_permissions](#output\_browser\_use\_permissions) | IAM permissions for using browser functionality |
| <a name="output_browser_use_policy"></a> [browser\_use\_policy](#output\_browser\_use\_policy) | Policy document for using browser functionality |

<!-- END_TF_DOCS -->