<!-- BEGIN_TF_DOCS -->
Primary entrypoint for the core\_interpreter submodule.

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
| [aws_iam_role.code_interpreter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.code_interpreter_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [awscc_bedrockagentcore_code_interpreter_custom.agent_code_interpreter](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_code_interpreter_custom) | resource |
| [time_sleep.code_interpreter_iam_role_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_code_interpreter_description"></a> [code\_interpreter\_description](#input\_code\_interpreter\_description) | Description of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, \_ (underscore), - (hyphen) and spaces. The description can have up to 200 characters. | `string` | `null` | no |
| <a name="input_code_interpreter_name"></a> [code\_interpreter\_name](#input\_code\_interpreter\_name) | The name of the agent core code interpreter. Valid characters are a-z, A-Z, 0-9, \_ (underscore). The name must start with a letter and can be up to 48 characters long. | `string` | `"TerraformBedrockAgentCoreCodeInterpreter"` | no |
| <a name="input_code_interpreter_network_configuration"></a> [code\_interpreter\_network\_configuration](#input\_code\_interpreter\_network\_configuration) | VPC network configuration for the agent core code interpreter. | <pre>object({<br/>    security_groups = optional(list(string))<br/>    subnets         = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_code_interpreter_network_mode"></a> [code\_interpreter\_network\_mode](#input\_code\_interpreter\_network\_mode) | Network mode configuration type for the agent core code interpreter. Valid values: SANDBOX, VPC. | `string` | `"SANDBOX"` | no |
| <a name="input_code_interpreter_role_arn"></a> [code\_interpreter\_role\_arn](#input\_code\_interpreter\_role\_arn) | Optional external IAM role ARN for the Bedrock agent core code interpreter. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_code_interpreter_tags"></a> [code\_interpreter\_tags](#input\_code\_interpreter\_tags) | A map of tag keys and values for the agent core code interpreter. Each tag key and value must be between 1 and 256 characters and can only include alphanumeric characters, spaces, and the following special characters: \_ . : / = + @ - | `map(string)` | `null` | no |
| <a name="input_create_code_interpreter"></a> [create\_code\_interpreter](#input\_create\_code\_interpreter) | Whether or not to create an agent core code interpreter custom. | `bool` | `false` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_code_interpreter_arn"></a> [agent\_code\_interpreter\_arn](#output\_agent\_code\_interpreter\_arn) | ARN of the created Bedrock AgentCore Code Interpreter Custom |
| <a name="output_agent_code_interpreter_created_at"></a> [agent\_code\_interpreter\_created\_at](#output\_agent\_code\_interpreter\_created\_at) | Creation timestamp of the created Bedrock AgentCore Code Interpreter Custom |
| <a name="output_agent_code_interpreter_failure_reason"></a> [agent\_code\_interpreter\_failure\_reason](#output\_agent\_code\_interpreter\_failure\_reason) | Failure reason if the Bedrock AgentCore Code Interpreter Custom failed |
| <a name="output_agent_code_interpreter_id"></a> [agent\_code\_interpreter\_id](#output\_agent\_code\_interpreter\_id) | ID of the created Bedrock AgentCore Code Interpreter Custom |
| <a name="output_agent_code_interpreter_last_updated_at"></a> [agent\_code\_interpreter\_last\_updated\_at](#output\_agent\_code\_interpreter\_last\_updated\_at) | Last update timestamp of the created Bedrock AgentCore Code Interpreter Custom |
| <a name="output_agent_code_interpreter_status"></a> [agent\_code\_interpreter\_status](#output\_agent\_code\_interpreter\_status) | Status of the created Bedrock AgentCore Code Interpreter Custom |
| <a name="output_code_interpreter_admin_permissions"></a> [code\_interpreter\_admin\_permissions](#output\_code\_interpreter\_admin\_permissions) | IAM permissions for code interpreter administration operations |
| <a name="output_code_interpreter_admin_policy"></a> [code\_interpreter\_admin\_policy](#output\_code\_interpreter\_admin\_policy) | Policy document for code interpreter administration |
| <a name="output_code_interpreter_full_access_permissions"></a> [code\_interpreter\_full\_access\_permissions](#output\_code\_interpreter\_full\_access\_permissions) | Full access IAM permissions for all code interpreter operations |
| <a name="output_code_interpreter_full_access_policy"></a> [code\_interpreter\_full\_access\_policy](#output\_code\_interpreter\_full\_access\_policy) | Policy document for granting full access to Bedrock AgentCore Code Interpreter operations |
| <a name="output_code_interpreter_invoke_permissions"></a> [code\_interpreter\_invoke\_permissions](#output\_code\_interpreter\_invoke\_permissions) | IAM permissions for invoking code interpreter |
| <a name="output_code_interpreter_invoke_policy"></a> [code\_interpreter\_invoke\_policy](#output\_code\_interpreter\_invoke\_policy) | Policy document for code interpreter invocation operations |
| <a name="output_code_interpreter_list_permissions"></a> [code\_interpreter\_list\_permissions](#output\_code\_interpreter\_list\_permissions) | IAM permissions for listing code interpreter resources |
| <a name="output_code_interpreter_list_policy"></a> [code\_interpreter\_list\_policy](#output\_code\_interpreter\_list\_policy) | Policy document for listing code interpreter resources |
| <a name="output_code_interpreter_read_permissions"></a> [code\_interpreter\_read\_permissions](#output\_code\_interpreter\_read\_permissions) | IAM permissions for reading code interpreter information |
| <a name="output_code_interpreter_read_policy"></a> [code\_interpreter\_read\_policy](#output\_code\_interpreter\_read\_policy) | Policy document for reading code interpreter information |
| <a name="output_code_interpreter_role_arn"></a> [code\_interpreter\_role\_arn](#output\_code\_interpreter\_role\_arn) | ARN of the IAM role created for the Bedrock AgentCore Code Interpreter Custom |
| <a name="output_code_interpreter_role_name"></a> [code\_interpreter\_role\_name](#output\_code\_interpreter\_role\_name) | Name of the IAM role created for the Bedrock AgentCore Code Interpreter Custom |
| <a name="output_code_interpreter_session_permissions"></a> [code\_interpreter\_session\_permissions](#output\_code\_interpreter\_session\_permissions) | IAM permissions for managing code interpreter sessions |
| <a name="output_code_interpreter_session_policy"></a> [code\_interpreter\_session\_policy](#output\_code\_interpreter\_session\_policy) | Policy document for code interpreter session management |
| <a name="output_code_interpreter_use_permissions"></a> [code\_interpreter\_use\_permissions](#output\_code\_interpreter\_use\_permissions) | IAM permissions for using code interpreter functionality |
| <a name="output_code_interpreter_use_policy"></a> [code\_interpreter\_use\_policy](#output\_code\_interpreter\_use\_policy) | Policy document for using code interpreter functionality |

<!-- END_TF_DOCS -->