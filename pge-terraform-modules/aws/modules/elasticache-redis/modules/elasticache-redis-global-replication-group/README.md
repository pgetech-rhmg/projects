<!-- BEGIN_TF_DOCS -->
# AWS Elasticache-redis module
Terraform module which creates SAF2.0 Elasticache-redis cluster global replication group in AWS.
KNOWN ERROR IN CREATING SECONDARY CLUSTER FOR THE GLOBAL REPLICATION GROUP
Error while updating the secondary cluster for the global replication group.
Error Message: "InvalidParameterCombination: Cannot use the given parameters when creating new replication group in an existing global replication group."
Reference Link: https://github.com/hashicorp/terraform-provider-aws/issues/24854

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_global_replication_group.global](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_global_replication_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Replication group identifier. This parameter is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_global_suffix"></a> [global\_suffix](#input\_global\_suffix) | The suffix name of a Global Datastore. If global\_replication\_group\_id\_suffix is changed, creates a new resource. | `string` | n/a | yes |
| <a name="input_primary_replication_group_id"></a> [primary\_replication\_group\_id](#input\_primary\_replication\_group\_id) | The ID of the primary cluster that accepts writes and will replicate updates to the secondary cluster. If primary\_replication\_group\_id is changed, creates a new resource. | `string` | n/a | yes |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine\_version\_actual. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_replication_group_arn"></a> [global\_replication\_group\_arn](#output\_global\_replication\_group\_arn) | The ARN of the ElastiCache Global Replication Group. |
| <a name="output_global_replication_group_at_rest_encryption_enabled"></a> [global\_replication\_group\_at\_rest\_encryption\_enabled](#output\_global\_replication\_group\_at\_rest\_encryption\_enabled) | A flag that indicate whether the encryption at rest is enabled. |
| <a name="output_global_replication_group_auth_token_enabled"></a> [global\_replication\_group\_auth\_token\_enabled](#output\_global\_replication\_group\_auth\_token\_enabled) | A flag that indicate whether AuthToken (password) is enabled. |
| <a name="output_global_replication_group_cache_node_type"></a> [global\_replication\_group\_cache\_node\_type](#output\_global\_replication\_group\_cache\_node\_type) | The instance class used |
| <a name="output_global_replication_group_cluster_enabled"></a> [global\_replication\_group\_cluster\_enabled](#output\_global\_replication\_group\_cluster\_enabled) | Indicates whether the Global Datastore is cluster enabled. |
| <a name="output_global_replication_group_engine"></a> [global\_replication\_group\_engine](#output\_global\_replication\_group\_engine) | The name of the cache engine to be used for the clusters in this global replication group. |
| <a name="output_global_replication_group_engine_version_actual"></a> [global\_replication\_group\_engine\_version\_actual](#output\_global\_replication\_group\_engine\_version\_actual) | The full version number of the cache engine running on the members of this global replication group |
| <a name="output_global_replication_group_global_replication_group_id"></a> [global\_replication\_group\_global\_replication\_group\_id](#output\_global\_replication\_group\_global\_replication\_group\_id) | The full ID of the global replication group. |
| <a name="output_global_replication_group_id"></a> [global\_replication\_group\_id](#output\_global\_replication\_group\_id) | The ID of the ElastiCache Global Replication Group. |
| <a name="output_global_replication_group_transit_encryption_enabled"></a> [global\_replication\_group\_transit\_encryption\_enabled](#output\_global\_replication\_group\_transit\_encryption\_enabled) | A flag that indicates whether the encryption in transit is enabled. |

<!-- END_TF_DOCS -->