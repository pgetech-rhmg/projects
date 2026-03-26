<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.53 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~> 0.53 |

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
| [null_resource.configure_auto_apply_run_triggers](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tfe_run_trigger.from_source_workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/run_trigger) | resource |
| [http_http.verify_workspace_settings](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [tfe_workspace.source_workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_auto_apply_run_triggers"></a> [enable\_auto\_apply\_run\_triggers](#input\_enable\_auto\_apply\_run\_triggers) | Enable auto-apply for run trigger runs | `bool` | `false` | no |
| <a name="input_source_workspace_name"></a> [source\_workspace\_name](#input\_source\_workspace\_name) | Source workspace name for run trigger (e.g., WS2). If provided, creates run trigger from source to this workspace. | `string` | `""` | no |
| <a name="input_tfc_organization"></a> [tfc\_organization](#input\_tfc\_organization) | Terraform Cloud organization name | `string` | n/a | yes |
| <a name="input_tfc_token"></a> [tfc\_token](#input\_tfc\_token) | Terraform Cloud API token for authentication | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | TFC Workspace ID (not name) for configuration | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | TFC Workspace name for reference | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_apply"></a> [auto\_apply](#output\_auto\_apply) | Whether auto-apply is enabled for all runs |
| <a name="output_auto_apply_run_triggers_enabled"></a> [auto\_apply\_run\_triggers\_enabled](#output\_auto\_apply\_run\_triggers\_enabled) | Whether auto-apply for run triggers is enabled |
| <a name="output_execution_mode"></a> [execution\_mode](#output\_execution\_mode) | Workspace execution mode |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | TFC Workspace ID |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | TFC Workspace Name |

<!-- END_TF_DOCS -->