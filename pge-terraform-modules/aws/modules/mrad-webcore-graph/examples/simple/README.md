# mrad-webcore-graph example


<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | ~> 2.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

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
| <a name="module_graph"></a> [graph](#module\_graph) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_version.sumo_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | n/a | `string` | n/a | yes |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where resources are created | `string` | n/a | yes |
| <a name="input_compliance"></a> [compliance](#input\_compliance) | n/a | `list(string)` | n/a | yes |
| <a name="input_create_graph"></a> [create\_graph](#input\_create\_graph) | Whether to create a Graph instance | `bool` | `false` | no |
| <a name="input_cris"></a> [cris](#input\_cris) | n/a | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | One of Dev, QA, or Prod | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | The GitHub token to use for the graph repo | `string` | n/a | yes |
| <a name="input_graph_repo_branch"></a> [graph\_repo\_branch](#input\_graph\_repo\_branch) | The branch to use for the graph repo | `string` | n/a | yes |
| <a name="input_notify"></a> [notify](#input\_notify) | n/a | `list(string)` | n/a | yes |
| <a name="input_order"></a> [order](#input\_order) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | `"engagetest"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project | `string` | `"Engage-Graph"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Appended to resource names to prevent collisions | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | This is auto-populated from the tfc workspace | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->