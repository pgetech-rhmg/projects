<!-- BEGIN_TF_DOCS -->
# AWS DocumentDB Cluster with single instance User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

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
| <a name="module_cluster_instance"></a> [cluster\_instance](#module\_cluster\_instance) | ../../modules/cluster_instance | n/a |
| <a name="module_cluster_parameter_group"></a> [cluster\_parameter\_group](#module\_cluster\_parameter\_group) | ../../modules/cluster_parameter_group | n/a |
| <a name="module_docdb_cluster"></a> [docdb\_cluster](#module\_docdb\_cluster) | ../.. | n/a |
| <a name="module_security_group_docdb"></a> [security\_group\_docdb](#module\_security\_group\_docdb) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_subnet_group"></a> [subnet\_group](#module\_subnet\_group) | ../../modules/subnet_group | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_password.cluster_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.cluster_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.docdb_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.docdb_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance    Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cluster_engine_version"></a> [cluster\_engine\_version](#input\_cluster\_engine\_version) | The database engine version. Updating this argument results in an outage. | `string` | n/a | yes |
| <a name="input_cluster_instance_instance_class"></a> [cluster\_instance\_instance\_class](#input\_cluster\_instance\_instance\_class) | The instance class to use. | `string` | n/a | yes |
| <a name="input_cluster_skip_final_snapshot"></a> [cluster\_skip\_final\_snapshot](#input\_cluster\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final\_snapshot\_identifier. | `string` | n/a | yes |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | aws\_docdb\_cluster provides the following Timeouts configuration options: create, update, delete | `map(string)` | n/a | yes |
| <a name="input_docdb_cluster_parameter_group_family"></a> [docdb\_cluster\_parameter\_group\_family](#input\_docdb\_cluster\_parameter\_group\_family) | The family of the documentDB cluster parameter group. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The common name for all the name arguments in resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_parameter"></a> [parameter](#input\_parameter) | A list of documentDB parameters to apply | `list(map(string))` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docdb_cluster_arn"></a> [docdb\_cluster\_arn](#output\_docdb\_cluster\_arn) | Amazon Resource Name (ARN) of cluster. |
| <a name="output_docdb_cluster_cluster_members"></a> [docdb\_cluster\_cluster\_members](#output\_docdb\_cluster\_cluster\_members) | List of DocDB Instances that are a part of this cluster. |
| <a name="output_docdb_cluster_endpoint"></a> [docdb\_cluster\_endpoint](#output\_docdb\_cluster\_endpoint) | The DNS address of the DocDB instance. |
| <a name="output_docdb_cluster_hosted_zone_id"></a> [docdb\_cluster\_hosted\_zone\_id](#output\_docdb\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint. |
| <a name="output_docdb_cluster_id"></a> [docdb\_cluster\_id](#output\_docdb\_cluster\_id) | The DocDB Cluster Identifier. |
| <a name="output_docdb_cluster_reader_endpoint"></a> [docdb\_cluster\_reader\_endpoint](#output\_docdb\_cluster\_reader\_endpoint) | A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas. |
| <a name="output_docdb_cluster_resource_id"></a> [docdb\_cluster\_resource\_id](#output\_docdb\_cluster\_resource\_id) | The DocDB Cluster Resource ID. |
| <a name="output_docdb_cluster_tags_all"></a> [docdb\_cluster\_tags\_all](#output\_docdb\_cluster\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_docdb_subnet_group_arn"></a> [docdb\_subnet\_group\_arn](#output\_docdb\_subnet\_group\_arn) | The ARN of the docdb subnet group. |
| <a name="output_docdb_subnet_group_id"></a> [docdb\_subnet\_group\_id](#output\_docdb\_subnet\_group\_id) | The docdb subnet group name. |
| <a name="output_docdb_subnet_group_tags_all"></a> [docdb\_subnet\_group\_tags\_all](#output\_docdb\_subnet\_group\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_documentdb_cluster_parameter_group_arn"></a> [documentdb\_cluster\_parameter\_group\_arn](#output\_documentdb\_cluster\_parameter\_group\_arn) | The ARN of the documentDB cluster parameter group. |
| <a name="output_documentdb_cluster_parameter_group_id"></a> [documentdb\_cluster\_parameter\_group\_id](#output\_documentdb\_cluster\_parameter\_group\_id) | The documentDB cluster parameter group name. |
| <a name="output_documentdb_cluster_parameter_group_tags_all"></a> [documentdb\_cluster\_parameter\_group\_tags\_all](#output\_documentdb\_cluster\_parameter\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->