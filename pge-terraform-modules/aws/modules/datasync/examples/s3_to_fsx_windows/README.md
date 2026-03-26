<!-- BEGIN_TF_DOCS -->
# AWS DataSync s3->fsx\_windows module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

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
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_datasync"></a> [datasync](#module\_datasync) | ../../ | n/a |
| <a name="module_fsx_destination"></a> [fsx\_destination](#module\_fsx\_destination) | ../../modules/fsx_windows_location | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_s3_source"></a> [s3\_source](#module\_s3\_source) | ../../modules/s3_location | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

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
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | n/a | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | The AWS service for which the role is being created. | `list(string)` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the source S3 bucket. | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group to which to send the logs. | `string` | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the FSx for Windows file system. | `string` | n/a | yes |
| <a name="input_fsx_location_arn"></a> [fsx\_location\_arn](#input\_fsx\_location\_arn) | The ARN of the FSx for Windows file system. | `string` | n/a | yes |
| <a name="input_fsx_password"></a> [fsx\_password](#input\_fsx\_password) | The FSx for Windows file system password. | `string` | n/a | yes |
| <a name="input_fsx_user"></a> [fsx\_user](#input\_fsx\_user) | The FSx for Windows file system user. | `string` | n/a | yes |
| <a name="input_gid"></a> [gid](#input\_gid) | The group ID to set on the FSx for Windows file system. | `string` | `"NONE"` | no |
| <a name="input_posix_permissions"></a> [posix\_permissions](#input\_posix\_permissions) | The POSIX permissions to set on the FSx for Windows file system. | `string` | `"NONE"` | no |
| <a name="input_s3_location_subdirectory"></a> [s3\_location\_subdirectory](#input\_s3\_location\_subdirectory) | The subdirectory in the S3 bucket. | `string` | n/a | yes |
| <a name="input_s3_role_name"></a> [s3\_role\_name](#input\_s3\_role\_name) | Name of the IAM role to be created for DataSync to access S3 bucket. | `string` | n/a | yes |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | The name of the DataSync task. | `string` | n/a | yes |
| <a name="input_uid"></a> [uid](#input\_uid) | The user ID to set on the FSx for Windows file system. | `string` | `"NONE"` | no |

## Outputs

No outputs.


<!-- END_TF_DOCS -->