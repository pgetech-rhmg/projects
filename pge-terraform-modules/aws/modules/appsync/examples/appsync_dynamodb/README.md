<!-- BEGIN_TF_DOCS -->
# AWS AppSync example
# Terraform module example usage for AppSync with Dynamodb as Datasource

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.4.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.4.3 |

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
| <a name="module_appsync_domain_name"></a> [appsync\_domain\_name](#module\_appsync\_domain\_name) | ../../modules/domain_name | n/a |
| <a name="module_appsync_domain_name_api_association"></a> [appsync\_domain\_name\_api\_association](#module\_appsync\_domain\_name\_api\_association) | ../../modules/domain_name_api_association | n/a |
| <a name="module_datasource"></a> [datasource](#module\_datasource) | ../../modules/datasource | n/a |
| <a name="module_dynamodb_table"></a> [dynamodb\_table](#module\_dynamodb\_table) | app.terraform.io/pgetech/dynamodb/aws | 0.1.1 |
| <a name="module_function"></a> [function](#module\_function) | ../../modules/function | n/a |
| <a name="module_graphql_api"></a> [graphql\_api](#module\_graphql\_api) | ../../ | n/a |
| <a name="module_graphql_api_iam_role"></a> [graphql\_api\_iam\_role](#module\_graphql\_api\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_resolver"></a> [resolver](#module\_resolver) | ../../modules/resolver | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.appsync_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.appsync_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.appsync_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_additional_authentication_provider_authentication_type"></a> [additional\_authentication\_provider\_authentication\_type](#input\_additional\_authentication\_provider\_authentication\_type) | One or more additional authentication providers for the GraphqlApi. | `string` | n/a | yes |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | Authentication type. Valid values: API\_KEY, AWS\_IAM, AMAZON\_COGNITO\_USER\_POOLS, OPENID\_CONNECT, AWS\_LAMBDA. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_caching_keys"></a> [caching\_keys](#input\_caching\_keys) | List of caching key. | `list(string)` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the certificate. This can be an Certificate Manager (ACM) certificate or an Identity and Access Management (IAM) server certificate. The certifiacte must reside in us-east-1. | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Client identifier of the Relying party at the OpenID identity provider. This identifier is typically obtained when the Relying party is registered with the OpenID identity provider. You can specify a regular expression so the AWS AppSync can validate against multiple client identifiers at a time. | `string` | n/a | yes |
| <a name="input_conflict_detection"></a> [conflict\_detection](#input\_conflict\_detection) | Conflict Detection strategy to use. Valid values are NONE and VERSION. | `string` | n/a | yes |
| <a name="input_conflict_handler"></a> [conflict\_handler](#input\_conflict\_handler) | Conflict Resolution strategy to perform in the event of a conflict. Valid values are NONE, OPTIMISTIC\_CONCURRENCY, AUTOMERGE, and LAMBDA. | `string` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | Add only this content to the archive with source\_content\_filename as the filename. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the  Domain name. | `string` | n/a | yes |
| <a name="input_domain_role_service"></a> [domain\_role\_service](#input\_domain\_role\_service) | Aws service of the IAM role | `list(string)` | n/a | yes |
| <a name="input_field"></a> [field](#input\_field) | Field name from the schema defined in the GraphQL API. | `string` | n/a | yes |
| <a name="input_filename"></a> [filename](#input\_filename) | Set this as the filename when using source\_content. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `string` | n/a | yes |
| <a name="input_hash_range_key_attributes"></a> [hash\_range\_key\_attributes](#input\_hash\_range\_key\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list(map(string))` | n/a | yes |
| <a name="input_issuer"></a> [issuer](#input\_issuer) | Issuer for the OpenID Connect configuration. The issuer returned by discovery MUST exactly match the value of iss in the ID Token. | `string` | n/a | yes |
| <a name="input_issuer2"></a> [issuer2](#input\_issuer2) | Issuer for the OpenID Connect configuration. The issuer returned by discovery MUST exactly match the value of iss in the ID Token. | `string` | n/a | yes |
| <a name="input_kind"></a> [kind](#input\_kind) | Resolver type. Valid values are UNIT and PIPELINE. | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | `list(any)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | User-supplied name for the GraphqlApi. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The attribute to use as the range (sort) key. Must also be defined as an attribute | `string` | `null` | no |
| <a name="input_request_mapping_template"></a> [request\_mapping\_template](#input\_request\_mapping\_template) | Function request mapping template. Functions support only the 2018-05-29 version of the request mapping template. | `string` | n/a | yes |
| <a name="input_request_template"></a> [request\_template](#input\_request\_template) | Request mapping template for UNIT resolver or 'before mapping template' for PIPELINE resolver. Required for non-Lambda resolvers. | `string` | n/a | yes |
| <a name="input_resolver_type"></a> [resolver\_type](#input\_resolver\_type) | Type name from the schema defined in the GraphQL API. | `string` | n/a | yes |
| <a name="input_response_mapping_template"></a> [response\_mapping\_template](#input\_response\_mapping\_template) | Function response mapping template. | `string` | n/a | yes |
| <a name="input_response_template"></a> [response\_template](#input\_response\_template) | Response mapping template for UNIT resolver or 'after mapping template' for PIPELINE resolver. Required for non-Lambda resolvers. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | enter the value of subnet id2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | enter the value of subnet id3 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Indicates whether Streams are to be enabled (true) or disabled (false). | `bool` | n/a | yes |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values for stream view type should be KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE and NEW\_AND\_OLD\_IMAGES when the stream is enabled and value must be null when stream is disabled. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | TTL in seconds. | `number` | n/a | yes |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | The name of the table attribute to store the TTL timestamp in | `string` | n/a | yes |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Indicates whether ttl is enabled | `bool` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Type of the Data Source. Valid values: AWS\_LAMBDA, AMAZON\_DYNAMODB, AMAZON\_ELASTICSEARCH, HTTP, NONE, RELATIONAL\_DATABASE. | `string` | n/a | yes |
| <a name="input_versioned"></a> [versioned](#input\_versioned) | Set to TRUE to use Conflict Detection and Resolution with this data source. | `bool` | n/a | yes |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Sets the value of the GraphQL API to public (GLOBAL) or private (PRIVATE). Defaults to GLOBAL if not set. Cannot be changed once set. | `string` | `null` | no |
| <a name="input_web_acl_arn"></a> [web\_acl\_arn](#input\_web\_acl\_arn) | The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource. | `string` | n/a | yes |
| <a name="input_xray_enabled"></a> [xray\_enabled](#input\_xray\_enabled) | Whether tracing with X-ray is enabled. Defaults to false. | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasource_all"></a> [datasource\_all](#output\_datasource\_all) | The ARN of the appsync datasource. |
| <a name="output_domain_all"></a> [domain\_all](#output\_domain\_all) | Domain name that AppSync provides. |
| <a name="output_domain_name_api_association_id_all"></a> [domain\_name\_api\_association\_id\_all](#output\_domain\_name\_api\_association\_id\_all) | AppSync domain name |
| <a name="output_function_all"></a> [function\_all](#output\_function\_all) | Unique ID representing the Function object. |
| <a name="output_graphql_all"></a> [graphql\_all](#output\_graphql\_all) | All output for graphql |
| <a name="output_resolver_arn_all"></a> [resolver\_arn\_all](#output\_resolver\_arn\_all) | ARN |


<!-- END_TF_DOCS -->