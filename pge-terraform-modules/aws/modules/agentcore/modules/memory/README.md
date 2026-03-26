<!-- BEGIN_TF_DOCS -->
Primary entrypoint for the memory submodule.

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
| [aws_iam_policy.memory_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.memory_self_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.memory_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.memory_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.memory_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.memory_self_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [awscc_bedrockagentcore_memory.agent_memory](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrockagentcore_memory) | resource |
| [time_sleep.memory_iam_role_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy.bedrock_memory_inference_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

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
| <a name="input_create_memory"></a> [create\_memory](#input\_create\_memory) | Whether or not to create an agent core memory. | `bool` | `false` | no |
| <a name="input_memory_description"></a> [memory\_description](#input\_memory\_description) | Description of the agent core memory. | `string` | `null` | no |
| <a name="input_memory_encryption_key_arn"></a> [memory\_encryption\_key\_arn](#input\_memory\_encryption\_key\_arn) | The ARN of the KMS key used to encrypt the memory. | `string` | `null` | no |
| <a name="input_memory_event_expiry_duration"></a> [memory\_event\_expiry\_duration](#input\_memory\_event\_expiry\_duration) | Duration in days until memory events expire. | `number` | `90` | no |
| <a name="input_memory_execution_role_arn"></a> [memory\_execution\_role\_arn](#input\_memory\_execution\_role\_arn) | Optional IAM role ARN for the Bedrock agent core memory. | `string` | `null` | no |
| <a name="input_memory_name"></a> [memory\_name](#input\_memory\_name) | The name of the agent core memory. | `string` | `"TerraformBedrockAgentCoreMemory"` | no |
| <a name="input_memory_strategies"></a> [memory\_strategies](#input\_memory\_strategies) | List of memory strategies attached to this memory. | <pre>list(object({<br/>    semantic_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    summary_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    user_preference_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>    }))<br/>    custom_memory_strategy = optional(object({<br/>      name        = optional(string)<br/>      description = optional(string)<br/>      namespaces  = optional(list(string))<br/>      configuration = optional(object({<br/>        self_managed_configuration = optional(object({<br/>          historical_context_window_size = optional(number, 4) # Default to 4 messages<br/>          invocation_configuration = object({<br/>            # Both fields are required when a self-managed configuration is used<br/>            payload_delivery_bucket_name = string<br/>            topic_arn                    = string<br/>          })<br/>          trigger_conditions = optional(list(object({<br/>            message_based_trigger = optional(object({<br/>              message_count = optional(number, 1) # Default to 1 message<br/>            }))<br/>            time_based_trigger = optional(object({<br/>              idle_session_timeout = optional(number, 10) # Default to 10 seconds<br/>            }))<br/>            token_based_trigger = optional(object({<br/>              token_count = optional(number, 100) # Default to 100 tokens<br/>            }))<br/>          })))<br/>        }))<br/>        semantic_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>          extraction = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>        summary_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>        user_preference_override = optional(object({<br/>          consolidation = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>          extraction = optional(object({<br/>            append_to_prompt = optional(string)<br/>            model_id         = optional(string)<br/>          }))<br/>        }))<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_memory_tags"></a> [memory\_tags](#input\_memory\_tags) | A map of tag keys and values for the agent core memory. | `map(string)` | `null` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_memory_arn"></a> [agent\_memory\_arn](#output\_agent\_memory\_arn) | ARN of the created Bedrock AgentCore Memory |
| <a name="output_agent_memory_created_at"></a> [agent\_memory\_created\_at](#output\_agent\_memory\_created\_at) | Creation timestamp of the created Bedrock AgentCore Memory |
| <a name="output_agent_memory_id"></a> [agent\_memory\_id](#output\_agent\_memory\_id) | ID of the created Bedrock AgentCore Memory |
| <a name="output_agent_memory_status"></a> [agent\_memory\_status](#output\_agent\_memory\_status) | Status of the created Bedrock AgentCore Memory |
| <a name="output_agent_memory_updated_at"></a> [agent\_memory\_updated\_at](#output\_agent\_memory\_updated\_at) | Last update timestamp of the created Bedrock AgentCore Memory |
| <a name="output_memory_admin_permissions"></a> [memory\_admin\_permissions](#output\_memory\_admin\_permissions) | IAM permissions for memory administration operations |
| <a name="output_memory_admin_policy"></a> [memory\_admin\_policy](#output\_memory\_admin\_policy) | Policy document for granting control plane admin permissions |
| <a name="output_memory_delete_permissions"></a> [memory\_delete\_permissions](#output\_memory\_delete\_permissions) | Combined IAM permissions for deleting from both Short-Term Memory (STM) and Long-Term Memory (LTM) |
| <a name="output_memory_delete_policy"></a> [memory\_delete\_policy](#output\_memory\_delete\_policy) | Policy document for granting delete permissions to both STM and LTM |
| <a name="output_memory_full_access_permissions"></a> [memory\_full\_access\_permissions](#output\_memory\_full\_access\_permissions) | Full access IAM permissions for all memory operations |
| <a name="output_memory_full_access_policy"></a> [memory\_full\_access\_policy](#output\_memory\_full\_access\_policy) | Policy document for granting full access to all memory operations |
| <a name="output_memory_kms_policy_arn"></a> [memory\_kms\_policy\_arn](#output\_memory\_kms\_policy\_arn) | ARN of the KMS policy for memory encryption (only available when KMS is provided) |
| <a name="output_memory_ltm_delete_permissions"></a> [memory\_ltm\_delete\_permissions](#output\_memory\_ltm\_delete\_permissions) | IAM permissions for deleting from Long-Term Memory (LTM) |
| <a name="output_memory_ltm_delete_policy"></a> [memory\_ltm\_delete\_policy](#output\_memory\_ltm\_delete\_policy) | Policy document for granting LTM delete permissions only |
| <a name="output_memory_ltm_read_permissions"></a> [memory\_ltm\_read\_permissions](#output\_memory\_ltm\_read\_permissions) | IAM permissions for reading from Long-Term Memory (LTM) |
| <a name="output_memory_ltm_read_policy"></a> [memory\_ltm\_read\_policy](#output\_memory\_ltm\_read\_policy) | Policy document for granting LTM read permissions only |
| <a name="output_memory_read_permissions"></a> [memory\_read\_permissions](#output\_memory\_read\_permissions) | Combined IAM permissions for reading from both Short-Term Memory (STM) and Long-Term Memory (LTM) |
| <a name="output_memory_read_policy"></a> [memory\_read\_policy](#output\_memory\_read\_policy) | Policy document for granting read permissions to both STM and LTM |
| <a name="output_memory_role_arn"></a> [memory\_role\_arn](#output\_memory\_role\_arn) | ARN of the IAM role created for the Bedrock AgentCore Memory |
| <a name="output_memory_role_name"></a> [memory\_role\_name](#output\_memory\_role\_name) | Name of the IAM role created for the Bedrock AgentCore Memory |
| <a name="output_memory_stm_delete_permissions"></a> [memory\_stm\_delete\_permissions](#output\_memory\_stm\_delete\_permissions) | IAM permissions for deleting from Short-Term Memory (STM) |
| <a name="output_memory_stm_delete_policy"></a> [memory\_stm\_delete\_policy](#output\_memory\_stm\_delete\_policy) | Policy document for granting STM delete permissions only |
| <a name="output_memory_stm_read_permissions"></a> [memory\_stm\_read\_permissions](#output\_memory\_stm\_read\_permissions) | IAM permissions for reading from Short-Term Memory (STM) |
| <a name="output_memory_stm_read_policy"></a> [memory\_stm\_read\_policy](#output\_memory\_stm\_read\_policy) | Policy document for granting STM read permissions only |
| <a name="output_memory_stm_write_permissions"></a> [memory\_stm\_write\_permissions](#output\_memory\_stm\_write\_permissions) | IAM permissions for writing to Short-Term Memory (STM) |
| <a name="output_memory_stm_write_policy"></a> [memory\_stm\_write\_policy](#output\_memory\_stm\_write\_policy) | Policy document for granting Short-Term Memory (STM) write permissions |

<!-- END_TF_DOCS -->