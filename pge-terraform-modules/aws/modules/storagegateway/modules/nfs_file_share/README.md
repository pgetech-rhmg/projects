<!-- BEGIN_TF_DOCS -->
# AWS storagegateway nfs\_file\_share module
# Terraform module which creates aws\_storagegateway\_nfs\_file\_share

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_storagegateway_nfs_file_share.nfs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_nfs_file_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audit_destination_arn"></a> [audit\_destination\_arn](#input\_audit\_destination\_arn) | The Amazon Resource Name (ARN) of the storage used for audit logs. | `string` | n/a | yes |
| <a name="input_cache_stale_timeout_in_seconds"></a> [cache\_stale\_timeout\_in\_seconds](#input\_cache\_stale\_timeout\_in\_seconds) | Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 300 to 2,592,000 seconds (5 minutes to 30 days). | `number` | `null` | no |
| <a name="input_client_list"></a> [client\_list](#input\_client\_list) | The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Set to ['0.0.0.0/0'] to not limit access. Minimum 1 item. Maximum 100 items. | `list(any)` | n/a | yes |
| <a name="input_default_storage_class"></a> [default\_storage\_class](#input\_default\_storage\_class) | he default storage class for objects put into an Amazon S3 bucket by the file gateway. Defaults to S3\_STANDARD. | `string` | `"S3_STANDARD"` | no |
| <a name="input_file_share_name"></a> [file\_share\_name](#input\_file\_share\_name) | The name of the file share. Must be set if an S3 prefix name is set in location\_arn. | `string` | `null` | no |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | Amazon Resource Name (ARN) of the file gateway. | `string` | n/a | yes |
| <a name="input_guess_mime_type_enabled"></a> [guess\_mime\_type\_enabled](#input\_guess\_mime\_type\_enabled) | Boolean value that enables guessing of the MIME type for uploaded objects based on file extensions. Defaults to true. | `bool` | `true` | no |
| <a name="input_kms_encrypted"></a> [kms\_encrypted](#input\_kms\_encrypted) | True to use AWS S3 server side encryption with PGE managed KMS key. False to use KMS key managed by AWS. Defaults to false. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Amazon Resource Name (ARN) for KMS key used for Amazon S3 server side encryption. This value can only be set when kms\_encrypted is true. | `string` | n/a | yes |
| <a name="input_location_arn"></a> [location\_arn](#input\_location\_arn) | The ARN of the backed storage used for storing file data. | `string` | n/a | yes |
| <a name="input_nfs_file_share_defaults"></a> [nfs\_file\_share\_defaults](#input\_nfs\_file\_share\_defaults) | {<br>nfs\_file\_share\_defaults : "Nested argument with file share default values."<br>directory\_mode : (Optional) The Unix directory mode in the string form "nnnn". Defaults to "0777".<br>file\_mode      : (Optional) The Unix file mode in the string form "nnnn". Defaults to "0666".<br>group\_id       : (Optional) The default group ID for the file share (unless the files have another group ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294.<br>owner\_id       : (Optional) The default owner ID for the file share (unless the files have another owner ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294.<br>} | <pre>object({<br>    directory_mode = optional(string)<br>    file_mode      = optional(string)<br>    group_id       = optional(number)<br>    owner_id       = optional(number)<br>  })</pre> | <pre>{<br>  "directory_mode": null,<br>  "file_mode": null,<br>  "group_id": null,<br>  "owner_id": null<br>}</pre> | no |
| <a name="input_notification_policy"></a> [notification\_policy](#input\_notification\_policy) | The notification policy of the file share. | `string` | `null` | no |
| <a name="input_read_only"></a> [read\_only](#input\_read\_only) | Boolean to indicate write status of file share. File share does not accept writes if true. Defaults to false. | `bool` | `false` | no |
| <a name="input_requester_pays"></a> [requester\_pays](#input\_requester\_pays) | Boolean who pays the cost of the request and the data download from the Amazon S3 bucket. Set this value to true if you want the requester to pay instead of the bucket owner. Defaults to false. | `bool` | `false` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage. | `string` | n/a | yes |
| <a name="input_squash"></a> [squash](#input\_squash) | Maps a user to anonymous user. Defaults to RootSquash. Valid values: RootSquash (only root is mapped to anonymous user), NoSquash (no one is mapped to anonymous user), AllSquash (everyone is mapped to anonymous user) | `string` | `"RootSquash"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | {<br>  create : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"<br>  update : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"<br>  delete : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 15m"<br>} | <pre>object({<br>    create = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | <pre>{<br>  "create": "10m",<br>  "delete": "10m",<br>  "update": "15m"<br>}</pre> | no |
| <a name="input_vpc_endpoint_bucket"></a> [vpc\_endpoint\_bucket](#input\_vpc\_endpoint\_bucket) | Object varaibles to check The region of the S3 bucket used by the file share. Required when specifying vpc\_endpoint\_dns\_name. | <pre>object({<br>    vpc_endpoint_dns_name = string<br>    bucket_region         = string<br>  })</pre> | <pre>{<br>  "bucket_region": "",<br>  "vpc_endpoint_dns_name": ""<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nfs_file_share_arn"></a> [nfs\_file\_share\_arn](#output\_nfs\_file\_share\_arn) | Amazon Resource Name (ARN) of the NFS File Share. |
| <a name="output_nfs_file_share_id"></a> [nfs\_file\_share\_id](#output\_nfs\_file\_share\_id) | Amazon Resource Name (ARN) of the NFS File Share. |
| <a name="output_nfs_fileshare_id"></a> [nfs\_fileshare\_id](#output\_nfs\_fileshare\_id) | ID of the NFS File Share. |
| <a name="output_nfs_path"></a> [nfs\_path](#output\_nfs\_path) | File share path used by the NFS client to identify the mount point. |
| <a name="output_nfs_tags_all"></a> [nfs\_tags\_all](#output\_nfs\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->