# mrad-webcore-pllambdas Example

This testing module requires the following commands to deploy correctly:

```
terraform plan -var=github_token=$GITHUB_TOKEN -var=create_lambdas_pipeline=true
terraform apply -var=github_token=$GITHUB_TOKEN -var=create_lambdas_pipeline=true
terraform destroy -var=github_token=$GITHUB_TOKEN -var=create_lambdas_pipeline=true
```

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
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
| <a name="module_pl_nlbman"></a> [pl\_nlbman](#module\_pl\_nlbman) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.0.5 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_compliance"></a> [compliance](#input\_compliance) | n/a | `list(string)` | n/a | yes |
| <a name="input_create_atrisk_pipeline"></a> [create\_atrisk\_pipeline](#input\_create\_atrisk\_pipeline) | Whether to create the ATRISK pipeline | `bool` | `false` | no |
| <a name="input_create_dbsched_pipeline"></a> [create\_dbsched\_pipeline](#input\_create\_dbsched\_pipeline) | Whether to create the DB Scheduler pipeline | `bool` | `false` | no |
| <a name="input_create_gisseed_pipeline"></a> [create\_gisseed\_pipeline](#input\_create\_gisseed\_pipeline) | Whether to create the GIS SEED pipeline | `bool` | `false` | no |
| <a name="input_create_gissync_pipeline"></a> [create\_gissync\_pipeline](#input\_create\_gissync\_pipeline) | Whether to create the GIS SYNC pipeline | `bool` | `false` | no |
| <a name="input_create_nlbman_pipeline"></a> [create\_nlbman\_pipeline](#input\_create\_nlbman\_pipeline) | Whether to create the NLB Manager pipeline | `bool` | `false` | no |
| <a name="input_create_pttup_pipeline"></a> [create\_pttup\_pipeline](#input\_create\_pttup\_pipeline) | Whether to create the PTT pipeline | `bool` | `false` | no |
| <a name="input_cris"></a> [cris](#input\_cris) | n/a | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | n/a | `string` | n/a | yes |
| <a name="input_notify"></a> [notify](#input\_notify) | n/a | `list(string)` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `list(string)` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->