<!-- BEGIN_TF_DOCS -->
# AWS Transfer Family with usage example
Terraform module which creates Transfer server for s3 in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| <a name="module_iam_transfer_role"></a> [iam\_transfer\_role](#module\_iam\_transfer\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_security_group_transfer_server"></a> [security\_group\_transfer\_server](#module\_security\_group\_transfer\_server) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_transfer_access"></a> [transfer\_access](#module\_transfer\_access) | ../../modules/transfer-access | n/a |
| <a name="module_transfer_server"></a> [transfer\_server](#module\_transfer\_server) | ../.. | n/a |
| <a name="module_transfer_workflow"></a> [transfer\_workflow](#module\_transfer\_workflow) | ../../modules/transfer-workflow | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.transfer_family](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | n/a | yes |
| <a name="input_bucket_object_key"></a> [bucket\_object\_key](#input\_bucket\_object\_key) | Name of the object once it is in the bucket. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_directory_id"></a> [directory\_id](#input\_directory\_id) | The directory service ID of the directory service you want to connect to with an identity\_provider\_type of AWS\_DIRECTORY\_SERVICE. | `string` | n/a | yes |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC\_ENDPOINT), your SFTP server isn't accessible over the public internet. | `string` | n/a | yes |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | The SID of a group in the directory connected to the Transfer Server. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS KMS role to assume | `string` | n/a | yes |
| <a name="input_local_zip_source_directory"></a> [local\_zip\_source\_directory](#input\_local\_zip\_source\_directory) | Package entire contents of this directory into the archive | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_source_file_location"></a> [source\_file\_location](#input\_source\_file\_location) | Specifies which file to use as input to the workflow step: either the output from the previous step, or the originally uploaded file for the workflow. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | enter the value of subnet id1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | enter the value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | Timeout, in seconds, for the step. | `number` | n/a | yes |
| <a name="input_type1"></a> [type1](#input\_type1) | One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG. | `string` | n/a | yes |
| <a name="input_type2"></a> [type2](#input\_type2) | One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG. | `string` | n/a | yes |
| <a name="input_type3"></a> [type3](#input\_type3) | One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG. | `string` | n/a | yes |
| <a name="input_type4"></a> [type4](#input\_type4) | One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transfer_access_id"></a> [transfer\_access\_id](#output\_transfer\_access\_id) | The ID of the resource. |
| <a name="output_transfer_server_arn"></a> [transfer\_server\_arn](#output\_transfer\_server\_arn) | Amazon Resource Name (ARN) of Transfer Server. |
| <a name="output_transfer_server_endpoint"></a> [transfer\_server\_endpoint](#output\_transfer\_server\_endpoint) | The endpoint of the Transfer Server. |
| <a name="output_transfer_server_host_key_fingerprint"></a> [transfer\_server\_host\_key\_fingerprint](#output\_transfer\_server\_host\_key\_fingerprint) | This value contains the message-digest algorithm (MD5) hash of the server's host key. This value is equivalent to the output of the ssh-keygen -l -E md5 -f my-new-server-key command. |
| <a name="output_transfer_server_id"></a> [transfer\_server\_id](#output\_transfer\_server\_id) | The Server ID of the Transfer Server. |
| <a name="output_transfer_server_tags_all"></a> [transfer\_server\_tags\_all](#output\_transfer\_server\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_transfer_workflow_arn"></a> [transfer\_workflow\_arn](#output\_transfer\_workflow\_arn) | The Workflow ARN. |
| <a name="output_transfer_workflow_id"></a> [transfer\_workflow\_id](#output\_transfer\_workflow\_id) | The Workflow id. |
| <a name="output_transfer_workflow_tags_all"></a> [transfer\_workflow\_tags\_all](#output\_transfer\_workflow\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->