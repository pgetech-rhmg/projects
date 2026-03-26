<!-- BEGIN_TF_DOCS -->


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
| <a name="module_emr_serverless_spark"></a> [emr\_serverless\_spark](#module\_emr\_serverless\_spark) | ../../modules/serverless | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="input_initial_capacity"></a> [initial\_capacity](#input\_initial\_capacity) | Initial capacity configuration for EMR Serverless | <pre>map(object({<br/>    initial_capacity_type = string<br/>    initial_capacity_config = optional(object({<br/>      worker_count = number<br/>      worker_configuration = optional(object({<br/>        cpu    = string<br/>        memory = string<br/>        disk   = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_interactive_configuration"></a> [interactive\_configuration](#input\_interactive\_configuration) | Configuration for interactive workloads in EMR Serverless, including Livy and Studio endpoints. | <pre>object({<br/>    livy_endpoint_enabled = optional(bool)<br/>    studio_enabled        = optional(bool)<br/>  })</pre> | `{}` | no |
| <a name="input_maximum_capacity"></a> [maximum\_capacity](#input\_maximum\_capacity) | Map of maximum capacity configurations for EMR Serverless applications | <pre>object({<br/>    cpu    = string<br/>    memory = string<br/>    disk   = optional(number)<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the EMR Serverless application | `string` | n/a | yes |
| <a name="input_monitoring_configuration"></a> [monitoring\_configuration](#input\_monitoring\_configuration) | The monitoring configuration for the application, prometheus_monitoring_configuration - Only supported in EMR 7.1.0 and later versions.| <pre>object({<br/>    cloudwatch_logging_configuration = optional(object({<br/>      enabled                = optional(bool)<br/>      log_group_name         = optional(string)<br/>      log_stream_name_prefix = optional(string)<br/>      encryption_key_arn     = optional(string)<br/>      log_types = optional(list(object({<br/>        name   = string<br/>        values = list(string)<br/>      })))<br/>    }))<br/>    managed_persistence_monitoring_configuration = optional(object({<br/>      enabled            = optional(bool)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>    prometheus_monitoring_configuration = optional(object({<br/>      remote_write_url = optional(string)<br/>    }))<br/>    s3_monitoring_configuration = optional(object({<br/>      log_uri            = optional(string)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_release_label_prefix"></a> [release\_label\_prefix](#input\_release\_label\_prefix) | Release label prefix used to lookup a release label | `string` | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_subnet_id2_name"></a> [subnet\_id2\_name](#input\_subnet\_id2\_name) | The name given in the parameter store for the subnet id 2 | `string` | n/a | yes |
| <a name="input_subnet_id3_name"></a> [subnet\_id3\_name](#input\_subnet\_id3\_name) | The name given in the parameter store for the subnet id 3 | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The type of application, e.g., SPARK or HIVE. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_spark_arn"></a> [spark\_arn](#output\_spark\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_spark_id"></a> [spark\_id](#output\_spark\_id) | ID of the application |

<!-- END_TF_DOCS -->