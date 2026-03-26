<!-- BEGIN_TF_DOCS -->
# AWS DMS Source Endpoint module.
Terraform module which creates SAF2.0 DMS Endpoint in AWS.

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| [aws_dms_endpoint.dms_source_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_endpoint.dms_target_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [external_external.validate_kms_source_endpoint_kms_key_arn](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.validate_kms_target_endpoint_kms_key_arn](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_source_certificate_arn"></a> [source\_certificate\_arn](#input\_source\_certificate\_arn) | ARN of the source SSL certificate | `string` | `null` | no |
| <a name="input_source_endpoint_database_name"></a> [source\_endpoint\_database\_name](#input\_source\_endpoint\_database\_name) | Name of the endpoint database. | `string` | `null` | no |
| <a name="input_source_endpoint_engine_name"></a> [source\_endpoint\_engine\_name](#input\_source\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_source_endpoint_extra_connection_attributes"></a> [source\_endpoint\_extra\_connection\_attributes](#input\_source\_endpoint\_extra\_connection\_attributes) | Additional attributes associated with the connection. | `string` | `null` | no |
| <a name="input_source_endpoint_id"></a> [source\_endpoint\_id](#input\_source\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_source_endpoint_kms_key_arn"></a> [source\_endpoint\_kms\_key\_arn](#input\_source\_endpoint\_kms\_key\_arn) | ARN for the KMS key that will be used to encrypt the connection parameters. | `string` | n/a | yes |
| <a name="input_source_endpoint_password"></a> [source\_endpoint\_password](#input\_source\_endpoint\_password) | Password to be used to login to the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_port"></a> [source\_endpoint\_port](#input\_source\_endpoint\_port) | Port used by the endpoint database. | `string` | n/a | yes |
| <a name="input_source_endpoint_server_name"></a> [source\_endpoint\_server\_name](#input\_source\_endpoint\_server\_name) | Host name of the server. | `string` | n/a | yes |
| <a name="input_source_endpoint_service_access_role"></a> [source\_endpoint\_service\_access\_role](#input\_source\_endpoint\_service\_access\_role) | ARN used by the service access IAM role for dynamodb endpoints. | `string` | `null` | no |
| <a name="input_source_endpoint_ssl_mode"></a> [source\_endpoint\_ssl\_mode](#input\_source\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_source_endpoint_username"></a> [source\_endpoint\_username](#input\_source\_endpoint\_username) | User name to be used to login to the endpoint database. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_target_certificate_arn"></a> [target\_certificate\_arn](#input\_target\_certificate\_arn) | ARN of the target SSL certificate | `string` | `null` | no |
| <a name="input_target_endpoint_database_name"></a> [target\_endpoint\_database\_name](#input\_target\_endpoint\_database\_name) | Name of the endpoint database. | `string` | `null` | no |
| <a name="input_target_endpoint_engine_name"></a> [target\_endpoint\_engine\_name](#input\_target\_endpoint\_engine\_name) | Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_target_endpoint_extra_connection_attributes"></a> [target\_endpoint\_extra\_connection\_attributes](#input\_target\_endpoint\_extra\_connection\_attributes) | Additional attributes associated with the connection. | `string` | `null` | no |
| <a name="input_target_endpoint_id"></a> [target\_endpoint\_id](#input\_target\_endpoint\_id) | Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | n/a | yes |
| <a name="input_target_endpoint_kms_key_arn"></a> [target\_endpoint\_kms\_key\_arn](#input\_target\_endpoint\_kms\_key\_arn) | ARN for the KMS key that will be used to encrypt the connection parameters. | `string` | n/a | yes |
| <a name="input_target_endpoint_password"></a> [target\_endpoint\_password](#input\_target\_endpoint\_password) | Password to be used to login to the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_port"></a> [target\_endpoint\_port](#input\_target\_endpoint\_port) | Port used by the endpoint database. | `string` | n/a | yes |
| <a name="input_target_endpoint_server_name"></a> [target\_endpoint\_server\_name](#input\_target\_endpoint\_server\_name) | Host name of the server. | `string` | n/a | yes |
| <a name="input_target_endpoint_service_access_role"></a> [target\_endpoint\_service\_access\_role](#input\_target\_endpoint\_service\_access\_role) | ARN used by the service access IAM role for dynamodb endpoints. | `string` | `null` | no |
| <a name="input_target_endpoint_ssl_mode"></a> [target\_endpoint\_ssl\_mode](#input\_target\_endpoint\_ssl\_mode) | SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAf, For each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'. | `string` | n/a | yes |
| <a name="input_target_endpoint_username"></a> [target\_endpoint\_username](#input\_target\_endpoint\_username) | User name to be used to login to the endpoint database. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dms_source_endpoint_all"></a> [dms\_source\_endpoint\_all](#output\_dms\_source\_endpoint\_all) | A map of aws dms source endpoint |
| <a name="output_dms_source_endpoint_arn"></a> [dms\_source\_endpoint\_arn](#output\_dms\_source\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_source_endpoint_tags_all"></a> [dms\_source\_endpoint\_tags\_all](#output\_dms\_source\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_dms_target_endpoint_all"></a> [dms\_target\_endpoint\_all](#output\_dms\_target\_endpoint\_all) | A map of aws dms target endpoint |
| <a name="output_dms_target_endpoint_arn"></a> [dms\_target\_endpoint\_arn](#output\_dms\_target\_endpoint\_arn) | ARN for the endpoint. |
| <a name="output_dms_target_endpoint_tags_all"></a> [dms\_target\_endpoint\_tags\_all](#output\_dms\_target\_endpoint\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->