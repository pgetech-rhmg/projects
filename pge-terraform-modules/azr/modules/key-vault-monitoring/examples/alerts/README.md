# Azure Key Vault Monitoring Example

This example demonstrates how to use the Key Vault Monitoring module to set up comprehensive monitoring and alerting for Azure Key Vaults.

## Usage

```bash
cd azr/modules/key-vault-monitoring/examples/default

terraform init

terraform validate

terraform plan

terraform apply
```

## Requirements

- Azure CLI configured with appropriate credentials
- Terraform >= 1.1.0
- Azurerm provider >= 3.0
- An existing action group for alert notifications
- Existing Key Vaults to monitor

## Inputs

See `variables.tf` for available variables and `terraform.auto.tfvars` for example values.

## Outputs

- `availability_alert_ids` - IDs of the Key Vault availability alerts
- `latency_alert_ids` - IDs of the Key Vault service API latency alerts
- `access_policy_change_alert_id` - ID of the access policy change alert
- `deletion_alert_id` - ID of the deletion alert
- `key_operations_alert_id` - ID of the key operations alert

## Features

This example creates:
- Metric alerts for availability, latency, and API performance
- Activity log alerts for access policy changes and deletions
- Optional diagnostic settings for Event Hub and Log Analytics integration

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

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
| <a name="module_kv_monitoring"></a> [kv\_monitoring](#module\_kv\_monitoring) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group"></a> [action\_group](#input\_action\_group) | The name of the action group to be used in alerts | `string` | n/a | yes |
| <a name="input_action_group_resource_group_name"></a> [action\_group\_resource\_group\_name](#input\_action\_group\_resource\_group\_name) | The name of the resource group where the action group is located | `string` | n/a | yes |
| <a name="input_availability_threshold"></a> [availability\_threshold](#input\_availability\_threshold) | Key Vault availability threshold percentage | `number` | `99.9` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `false` | no |
| <a name="input_eventhub_authorization_rule_name"></a> [eventhub\_authorization\_rule\_name](#input\_eventhub\_authorization\_rule\_name) | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Name of the Event Hub | `string` | `""` | no |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | Name of the Event Hub namespace | `string` | `""` | no |
| <a name="input_eventhub_resource_group_name"></a> [eventhub\_resource\_group\_name](#input\_eventhub\_resource\_group\_name) | Resource group name of the Event Hub namespace | `string` | `""` | no |
| <a name="input_eventhub_subscription_id"></a> [eventhub\_subscription\_id](#input\_eventhub\_subscription\_id) | Subscription ID where the Event Hub namespace is located | `string` | `""` | no |
| <a name="input_key_vault_names"></a> [key\_vault\_names](#input\_key\_vault\_names) | List of Key Vault names to monitor | `list(string)` | n/a | yes |
| <a name="input_log_analytics_resource_group_name"></a> [log\_analytics\_resource\_group\_name](#input\_log\_analytics\_resource\_group\_name) | Resource group name of the Log Analytics workspace | `string` | `""` | no |
| <a name="input_log_analytics_subscription_id"></a> [log\_analytics\_subscription\_id](#input\_log\_analytics\_subscription\_id) | Subscription ID where the Log Analytics workspace is located | `string` | `""` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the Log Analytics workspace | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Key Vaults are located | `string` | n/a | yes |
| <a name="input_saturation_shoebox_threshold"></a> [saturation\_shoebox\_threshold](#input\_saturation\_shoebox\_threshold) | Saturation shoebox threshold percentage | `number` | `75` | no |
| <a name="input_service_api_hit_threshold"></a> [service\_api\_hit\_threshold](#input\_service\_api\_hit\_threshold) | Service API hit rate threshold | `number` | `1000` | no |
| <a name="input_service_api_latency_threshold"></a> [service\_api\_latency\_threshold](#input\_service\_api\_latency\_threshold) | Service API latency threshold in milliseconds | `number` | `1000` | no |
| <a name="input_service_api_result_threshold"></a> [service\_api\_result\_threshold](#input\_service\_api\_result\_threshold) | Service API result threshold for errors | `number` | `10` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policy_change_alert_id"></a> [access\_policy\_change\_alert\_id](#output\_access\_policy\_change\_alert\_id) | ID of the Key Vault access policy change alert |
| <a name="output_availability_alert_ids"></a> [availability\_alert\_ids](#output\_availability\_alert\_ids) | IDs of the Key Vault availability alerts |
| <a name="output_deletion_alert_id"></a> [deletion\_alert\_id](#output\_deletion\_alert\_id) | ID of the Key Vault deletion alert |
| <a name="output_key_operations_alert_id"></a> [key\_operations\_alert\_id](#output\_key\_operations\_alert\_id) | ID of the Key Vault key operations alert |
| <a name="output_latency_alert_ids"></a> [latency\_alert\_ids](#output\_latency\_alert\_ids) | IDs of the Key Vault service API latency alerts |

<!-- END_TF_DOCS -->