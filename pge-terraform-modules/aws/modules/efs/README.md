# AWS EFS Terraform module

Terraform module which creates EFS file system.

## Usage
##### Efs with a custom policy
```hcl

module "efs" {
  source = "../../../../modules/efs"

  kms_key_id        = module.kms_key.key_arn
  root_directory    = var.root_directory
  access_point_tags = module.tags.tags
  subnet_id         = var.subnet_id
  security_groups   = [module.security_group.sg_id]
  policy            = data.template_file.efs_custom_policy.rendered
  tags              = merge(module.tags.tags, local.optional_tags)
}
  
```
##### Efs with Ec2 mount
```hcl

module "efs" {
  source = "../../../../modules/efs"

  kms_key_id        = module.kms_key.key_arn
  root_directory    = var.root_directory
  access_point_tags = module.tags.tags
  subnet_id         = var.subnet_id
  security_groups   = [module.security_group.sg_id]
  tags              = merge(module.tags.tags, local.optional_tags)
}
  
```
##### Efs with lifecycle policy
```hcl

module "efs" {
  source = "../../../../modules/efs"

  transition_to_ia                    = var.transition_to_ia
  transition_to_primary_storage_class = var.transition_to_primary_storage_class
  kms_key_id                          = module.kms_key.key_arn
  root_directory                      = var.root_directory
  access_point_tags                   = module.tags.tags
  subnet_id                           = var.subnet_id
  security_groups                     = [module.security_group.sg_id]
  tags                                = merge(module.tags.tags, local.optional_tags)
}
  
```
##### Efs with one zone az
```hcl

module "efs" {
  source = "../../../../modules/efs"

  efs_one_zone_az   = var.efs_one_zone_az
  kms_key_id        = module.kms_key.key_arn
  root_directory    = var.root_directory
  access_point_tags = module.tags.tags
  subnet_id         = var.subnet_id
  security_groups   = [module.security_group.sg_id]
  tags              = merge(module.tags.tags, local.optional_tags)
}
  
```
##### Efs with pge policy
```hcl

module "efs" {
  source = "../../../../modules/efs"

  kms_key_id        = module.kms_key.key_arn
  root_directory    = var.root_directory
  access_point_tags = module.tags.tags
  subnet_id         = var.subnet_id
  security_groups   = [module.security_group.sg_id]
  tags              = merge(module.tags.tags, local.optional_tags)
}
  
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.27 |


## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_access_point.efs_access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_mount_target.efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_file_system_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_backup_policy.efs_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |

## Inputs


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| efs_one_zone_az | The names of the availability zone.The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. The default value is set as null because if user needs to use a single availability zone. | `string` | `null` | no |
| kms_key_id | The id of kms key | `string` | `null` | yes |
| transition_to_ia | Indicates how long it takes to transition files to the IA storage class | `string` | `null` | no |
| transition_to_primary_storage_class | Describes the policy used to transition a file from infequent access storage to primary storage | `string` | `null` | no |
| throughput_mode | Throughput mode for the file system | `string` | `bursting` | no |
| provisioned_throughput | The throughput provisioned for the file system. Only applicable with throughput_mode set to provisioned | `string` | `null` | no |
| performance_mode | The file system performance mode. | `string` | `generalPurpose` | no |
| tags | A mapping of tags to assign to the file system | `map(string)` | `null` | yes |
| posix_user_file_system | Operating system user and group applied to all file system requests made using the access point. | `bool` | `false` | no |
| posix_user_gid | POSIX group ID used for all file system operations using this access point."  | `number` | `null` | no |
| posix_user_secondary_gids | Secondary POSIX group IDs used for all file system operations using this access point.  | `list(number)` | `null` | no |
| posix_user_uid | POSIX user ID used for all file system operations using this access point.  | `number` | `null` | no |
| subnet_id | The ID of the subnet to add the mount target | `string` | `null` | yes |
| security_groups | A list of up to 5 VPC security group IDs in effect for the mount target. | `list(string)` | `null` | yes |
| policy | Valid JSON document representing a resource policy | `string` | `null` | yes |
| backup_status | EFS Backup Status ENABLED or DISABLED | `string` | `DISABLED` | no |


## Outputs

| Name | Description |
|------|-------------|
| efs_id | The ID that identifies the file system | 
| efs_arn | Amazon Resource Name of the file system | 
| efs_dns_name | The DNS name for the filesystem | 
| efs_access_point_arn | ARN of the access point |
| efs_access_point_id | ID of the access point |
| efs_mount_target_id | The ID of the mount target |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
# AWS EFS module
Terraform module which creates SAF2.0 EFS in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.efs_access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.efs_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.efs_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_status"></a> [backup\_status](#input\_backup\_status) | EFS Backup Status ENABLED or DISABLED | `string` | `"DISABLED"` | no |
| <a name="input_efs_one_zone_az"></a> [efs\_one\_zone\_az](#input\_efs\_one\_zone\_az) | The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. | `string` | `null` | no |
| <a name="input_enable_transition_to_primary_storage_class"></a> [enable\_transition\_to\_primary\_storage\_class](#input\_enable\_transition\_to\_primary\_storage\_class) | Input from the user to enable or disable transition\_to\_primary\_storage\_class | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The arn for the kms encryption key | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode | `string` | `"generalPurpose"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Valid JSON document representing a resource policy | `any` | `"{}"` | no |
| <a name="input_posix_user_file_system"></a> [posix\_user\_file\_system](#input\_posix\_user\_file\_system) | Operating system user and group applied to all file system requests made using the access point. | `bool` | `false` | no |
| <a name="input_posix_user_gid"></a> [posix\_user\_gid](#input\_posix\_user\_gid) | POSIX group ID used for all file system operations using this access point. | `number` | `null` | no |
| <a name="input_posix_user_secondary_gids"></a> [posix\_user\_secondary\_gids](#input\_posix\_user\_secondary\_gids) | Secondary POSIX group IDs used for all file system operations using this access point. | `list(number)` | `null` | no |
| <a name="input_posix_user_uid"></a> [posix\_user\_uid](#input\_posix\_user\_uid) | POSIX user ID used for all file system operations using this access point. | `number` | `null` | no |
| <a name="input_provisioned_throughput"></a> [provisioned\_throughput](#input\_provisioned\_throughput) | The throughput provisioned for the file system. Only applicable with throughput\_mode set to provisioned | `number` | `null` | no |
| <a name="input_root_directory"></a> [root\_directory](#input\_root\_directory) | Root directory for the access point | `list(any)` | <pre>[<br/>  {<br/>    "path": "/"<br/>  }<br/>]</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of up to 5 VPC security group IDs in effect for the mount target. | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet to add the mount target | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign resources for EFS | `map(string)` | n/a | yes |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode for the file system | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition\_to\_ia](#input\_transition\_to\_ia) | Indicates how long it takes to transition files to the IA storage class | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_access_point_arn"></a> [efs\_access\_point\_arn](#output\_efs\_access\_point\_arn) | ARN of the access point. |
| <a name="output_efs_access_point_id"></a> [efs\_access\_point\_id](#output\_efs\_access\_point\_id) | ID of the access point. |
| <a name="output_efs_all"></a> [efs\_all](#output\_efs\_all) | All attributes of EFS |
| <a name="output_efs_arn"></a> [efs\_arn](#output\_efs\_arn) | The ARN of EFS |
| <a name="output_efs_dns_name"></a> [efs\_dns\_name](#output\_efs\_dns\_name) | The DNS name for EFS |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | The ID of EFS |
| <a name="output_efs_mount_target_id"></a> [efs\_mount\_target\_id](#output\_efs\_mount\_target\_id) | The ID of the mount target. |

<!-- END_TF_DOCS -->