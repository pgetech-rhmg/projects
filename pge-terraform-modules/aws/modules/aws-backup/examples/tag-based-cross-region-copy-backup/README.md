<!-- BEGIN_TF_DOCS -->
AWS Backup example - This Example shows how to copy backups to a different region. Resources will be selected based on the tags assigned to them.
Terraform module which creates SAF2.0 AWS Backup resources in AWS
Pre-requisites - The ARN of a multi-region KMS key and its replicated Key is required.

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
| <a name="module_aws-backup-plan"></a> [aws-backup-plan](#module\_aws-backup-plan) | ../../ | n/a |
| <a name="module_aws-backup-resource-selection"></a> [aws-backup-resource-selection](#module\_aws-backup-resource-selection) | ../../modules/backup-resource-selection/ | n/a |
| <a name="module_aws-backup-vault"></a> [aws-backup-vault](#module\_aws-backup-vault) | ../../modules/backup-vault/ | n/a |
| <a name="module_aws-backup-vault-replica"></a> [aws-backup-vault-replica](#module\_aws-backup-vault-replica) | ../../modules/backup-vault/ | n/a |
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.sns-topic-backup-notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

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
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory. | `string` | n/a | yes |
| <a name="input_aws_backup_plan_name"></a> [aws\_backup\_plan\_name](#input\_aws\_backup\_plan\_name) | The display name of a backup plan | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_backup_rule_completion_window"></a> [backup\_rule\_completion\_window](#input\_backup\_rule\_completion\_window) | The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error. | `string` | n/a | yes |
| <a name="input_backup_rule_delete_after"></a> [backup\_rule\_delete\_after](#input\_backup\_rule\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. | `string` | n/a | yes |
| <a name="input_backup_rule_name"></a> [backup\_rule\_name](#input\_backup\_rule\_name) | The display name for a backup rule | `string` | n/a | yes |
| <a name="input_backup_rule_schedule"></a> [backup\_rule\_schedule](#input\_backup\_rule\_schedule) | A CRON expression specifying when AWS Backup initiates a backup job. | `string` | n/a | yes |
| <a name="input_backup_rule_start_window"></a> [backup\_rule\_start\_window](#input\_backup\_rule\_start\_window) | The amount of time in minutes before beginning a backup. | `string` | n/a | yes |
| <a name="input_backup_selection_name"></a> [backup\_selection\_name](#input\_backup\_selection\_name) | The display name of a resource selection document. | `string` | n/a | yes |
| <a name="input_backup_vault_events"></a> [backup\_vault\_events](#input\_backup\_vault\_events) | An array of events that indicate the status of jobs to back up resources to the backup vault. | `list(string)` | n/a | yes |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Set it false if a new KMS key to be generated | `bool` | `true` | no |
| <a name="input_create_vault_notifications"></a> [create\_vault\_notifications](#input\_create\_vault\_notifications) | Change to true if vault notifications needs to be enabled | `bool` | n/a | yes |
| <a name="input_destination_vault_delete_after"></a> [destination\_vault\_delete\_after](#input\_destination\_vault\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | IAM Role Name | `string` | `null` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_policy_arns_list"></a> [policy\_arns\_list](#input\_policy\_arns\_list) | A list of managed IAM policies to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | n/a | yes |
| <a name="input_replica_vault_name"></a> [replica\_vault\_name](#input\_replica\_vault\_name) | Name of the replica backup vault to create | `string` | n/a | yes |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | An array of tag condition objects used to filter resources based on tags for assigning to a backup plan | `any` | n/a | yes |
| <a name="input_sns_policy_file_name"></a> [sns\_policy\_file\_name](#input\_sns\_policy\_file\_name) | Valid JSON document representing a resource policy | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the backup vault to create | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arn"></a> [backup\_plan\_arn](#output\_backup\_plan\_arn) | The ARN of the backup plan |
| <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id) | The id of the backup plan |
| <a name="output_backup_plan_version"></a> [backup\_plan\_version](#output\_backup\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | The ARN of the vault |
| <a name="output_vault_arn_replica"></a> [vault\_arn\_replica](#output\_vault\_arn\_replica) | The ARN of the vault |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | The name of the vault |
| <a name="output_vault_id_replica"></a> [vault\_id\_replica](#output\_vault\_id\_replica) | The name of the vault |
| <a name="output_vault_recovery_points"></a> [vault\_recovery\_points](#output\_vault\_recovery\_points) | The number of recovery points that are stored in a backup vault |
| <a name="output_vault_recovery_points_replica"></a> [vault\_recovery\_points\_replica](#output\_vault\_recovery\_points\_replica) | The number of recovery points that are stored in a backup vault |


<!-- END_TF_DOCS -->