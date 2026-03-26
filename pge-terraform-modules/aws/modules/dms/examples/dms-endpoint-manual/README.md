<!-- BEGIN_TF_DOCS -->
# AWS DMS with usage example
Terraform module which creates SAF2.0 dms resources in AWS.
SSM Parameter store for storing username and password is a pre-requisite and must be existing to run this example.

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
| <a name="module_dms_endpoint"></a> [dms\_endpoint](#module\_dms\_endpoint) | ../../modules/dms_endpoint_manual | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.dms_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.dms_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_source_certificate_arn"></a> [source\_certificate\_arn](#input\_source\_certificate\_arn) | ARN of the source SSL certificate | `string` | n/a | yes |
| <a name="input_source_endpoint_database_name"></a> [source\_endpoint\_database\_name](#input\_source\_endpoint\_database\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_engine_name"></a> [source\_endpoint\_engine\_name](#input\_source\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_source_endpoint_id"></a> [source\_endpoint\_id](#input\_source\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_source_endpoint_port"></a> [source\_endpoint\_port](#input\_source\_endpoint\_port) | Port used by the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_server_name"></a> [source\_endpoint\_server\_name](#input\_source\_endpoint\_server\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_ssl_mode"></a> [source\_endpoint\_ssl\_mode](#input\_source\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_ssm_parameter_dms_password"></a> [ssm\_parameter\_dms\_password](#input\_ssm\_parameter\_dms\_password) | enter the value of dms\_password stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_dms_username"></a> [ssm\_parameter\_dms\_username](#input\_ssm\_parameter\_dms\_username) | Enter the value of dms\_username stored in ssm parameter | `string` | n/a | yes |
| <a name="input_target_certificate_arn"></a> [target\_certificate\_arn](#input\_target\_certificate\_arn) | ARN of the target SSL certificate | `string` | n/a | yes |
| <a name="input_target_endpoint_database_name"></a> [target\_endpoint\_database\_name](#input\_target\_endpoint\_database\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_engine_name"></a> [target\_endpoint\_engine\_name](#input\_target\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_target_endpoint_id"></a> [target\_endpoint\_id](#input\_target\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_target_endpoint_password"></a> [target\_endpoint\_password](#input\_target\_endpoint\_password) | Password to be used to login to the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_port"></a> [target\_endpoint\_port](#input\_target\_endpoint\_port) | Port used by the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_server_name"></a> [target\_endpoint\_server\_name](#input\_target\_endpoint\_server\_name) | Name of the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_ssl_mode"></a> [target\_endpoint\_ssl\_mode](#input\_target\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_target_endpoint_username"></a> [target\_endpoint\_username](#input\_target\_endpoint\_username) | User name to be used to login to the endpoint database. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_source_endpoint_arn"></a> [dms\_source\_endpoint\_arn](#output\_dms\_source\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_source_endpoint_tags_all"></a> [dms\_source\_endpoint\_tags\_all](#output\_dms\_source\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_dms_target_endpoint_arn"></a> [dms\_target\_endpoint\_arn](#output\_dms\_target\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_target_endpoint_tags_all"></a> [dms\_target\_endpoint\_tags\_all](#output\_dms\_target\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->