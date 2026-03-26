<!-- BEGIN_TF_DOCS -->
# AWS AppConfig User module example

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
| <a name="module_deployment_strategy"></a> [deployment\_strategy](#module\_deployment\_strategy) | ../../modules/deployment_strategy | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bake_time"></a> [bake\_time](#input\_bake\_time) | Amount of time AppConfig monitors for alarms before consdiering the deployment complete and no longer eligble for automatic roll back. 0 <= x <= 1440 | `number` | `0` | no |
| <a name="input_deployment_duration"></a> [deployment\_duration](#input\_deployment\_duration) | The duration of the AppConfig deployment. 0 <= x <= 1440 | `number` | `0` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig deployment strategy. | `string` | `null` | no |
| <a name="input_growth_factor"></a> [growth\_factor](#input\_growth\_factor) | Percentage of targets to receive a deployed configuration during each interval. 1 <= x <= 100 | `number` | `100` | no |
| <a name="input_growth_type"></a> [growth\_type](#input\_growth\_type) | Algorithm used to define how percentage grows over time. Either LINEAR or EXPONENTIAL. Default LINEAR | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AppConfig deployment strategy. | `string` | `null` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_replicate_to"></a> [replicate\_to](#input\_replicate\_to) | Where to save the deployment strategy. Either NONE or SSM\_DOCUMENT | `string` | `"NONE"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The AppConfig deployment strategy ARN |
| <a name="output_id"></a> [id](#output\_id) | The AppConfig deployment strategy ID |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of all tags assigned to the resource. |

<!-- END_TF_DOCS -->