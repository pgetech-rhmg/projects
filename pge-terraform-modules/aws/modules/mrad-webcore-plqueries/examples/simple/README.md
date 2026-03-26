# awm-webcore-plqueries Example

This testing module requires the following commands to deploy correctly:

```
terraform plan -var=github_token=$GITHUB_TOKEN -var=create_queries_pipeline=true
terraform apply -var=github_token=$GITHUB_TOKEN -var=create_queries_pipeline=true
terraform destroy -var=github_token=$GITHUB_TOKEN -var=create_queries_pipeline=true
```


<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.5 |

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
| <a name="module_pl_queries"></a> [pl\_queries](#module\_pl\_queries) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.0.5 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_compliance"></a> [compliance](#input\_compliance) | n/a | `list(string)` | n/a | yes |
| <a name="input_create_queries_pipeline"></a> [create\_queries\_pipeline](#input\_create\_queries\_pipeline) | Whether to create the queries pipeline | `bool` | `false` | no |
| <a name="input_cris"></a> [cris](#input\_cris) | n/a | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | n/a | `string` | n/a | yes |
| <a name="input_notify"></a> [notify](#input\_notify) | n/a | `list(string)` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `string` | n/a | yes |
| <a name="input_queries_repo_branch"></a> [queries\_repo\_branch](#input\_queries\_repo\_branch) | n/a | `string` | n/a | yes |
| <a name="input_queries_repo_name"></a> [queries\_repo\_name](#input\_queries\_repo\_name) | queries repository identifiers | `string` | n/a | yes |
| <a name="input_queries_repo_org"></a> [queries\_repo\_org](#input\_queries\_repo\_org) | The github organization that the queries repo belongs to. Must be one of pgetech or PGEDigitalCatalyst | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Appended to resource names to prevent collisions | `string` | n/a | yes |
| <a name="input_target_workspace"></a> [target\_workspace](#input\_target\_workspace) | The workspace resources that this pipeline will deploy into | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->