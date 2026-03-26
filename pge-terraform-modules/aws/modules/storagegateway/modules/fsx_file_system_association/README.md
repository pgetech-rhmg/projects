<!-- BEGIN_TF_DOCS -->
# AWS Storage gateway fsx file system association
Terraform module which creates SAF2.0 storage gateway fsx file system association in AWS.

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
| [aws_storagegateway_file_system_association.file_system_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_file_system_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audit_destination_arn"></a> [audit\_destination\_arn](#input\_audit\_destination\_arn) | The Amazon Resource Name (ARN) of the storage used for the audit logs. | `string` | n/a | yes |
| <a name="input_cache_stale_timeout_in_seconds"></a> [cache\_stale\_timeout\_in\_seconds](#input\_cache\_stale\_timeout\_in\_seconds) | Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 0 or 300 to 2592000 seconds (5 minutes to 30 days). Defaults to 0. | `number` | `0` | no |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | Amazon Resource Name (ARN) of the file gateway. | `string` | n/a | yes |
| <a name="input_location_arn"></a> [location\_arn](#input\_location\_arn) | The Amazon Resource Name (ARN) of the Amazon FSx file system to associate with the FSx File Gateway. | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | The password of the user credential. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | The user name of the user credential that has permission to access the root share of the Amazon FSx file system. The user account must belong to the Amazon FSx delegated admin user group. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_system_association_arn"></a> [file\_system\_association\_arn](#output\_file\_system\_association\_arn) | Amazon Resource Name (ARN) of the newly created file system association. |
| <a name="output_file_system_association_id"></a> [file\_system\_association\_id](#output\_file\_system\_association\_id) | Amazon Resource Name (ARN) of the FSx file system association. |
| <a name="output_file_system_association_tags_all"></a> [file\_system\_association\_tags\_all](#output\_file\_system\_association\_tags\_all) | A map of tags assigned to the resource. |


<!-- END_TF_DOCS -->