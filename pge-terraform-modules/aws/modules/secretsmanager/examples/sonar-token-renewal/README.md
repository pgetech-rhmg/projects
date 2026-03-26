<!-- BEGIN_TF_DOCS -->
#### A Reference to rotate SonarQube Token

**What this code does:**
- Updates provided SonarQube token to Secrets Manager.
- Enables Secrets manager automated rotation for provided number of days (83days).
- Regenrates new token using Lambda function with SonarQube API's
- Sends email notification with the status of rotation (success/failed).

**PreRequisites:**
- Create SonarQube token manually for the first time by following instructions here  - [Onboarding to SonarQube](https://wiki.comp.pge.com/display/CCE/Onboarding+to+SonarQube)
- Onboard to terraform Workspace if not already - [OnBoarding Terraform Cloud](https://wiki.comp.pge.com/display/CCE/OnBoarding+Terraform+Cloud)

**High Level Steps Included on this Automation:**
- Creation of Secrets manager credentials with provided secrets manager name and token by following PG&E standards \
such as encrypting credentials with custom KMS key, enabling secrets rotation and adding required tags.
- Creation of AWS Lambda function to generate new SonarQube token with a 90 day expiration and \
uploading generated token back to secrets manager. This function has been written in Python3 language.  
- Creation of KMS key and IAM polices as required to encrypt and access lambda & secrets manager.
- This automation supports storing credentials as either in PlainText or Key/Value pair.

For Detailed instrcutions, refer following [wiki](https://wiki.comp.pge.com/display/CCE/SonarQube+token+upload+to+secrets+manager+and+automatic+renewal+of+the+token)

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.76.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

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
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_layer"></a> [lambda\_layer](#module\_lambda\_layer) | app.terraform.io/pgetech/lambda/aws//modules/lambda_layer_version_local | 0.1.3 |
| <a name="module_secretsmanager"></a> [secretsmanager](#module\_secretsmanager) | ../../ | n/a |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [null_resource.install_python_layer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_key_value_secret"></a> [key\_value\_secret](#input\_key\_value\_secret) | Specifies key value data that you want to encrypt and store in this version of the secret | `map(string)` | `{}` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or Id of the AWS KMS customer master key | `string` | `""` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_lambda_cidr_egress_rules"></a> [lambda\_cidr\_egress\_rules](#input\_lambda\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_lambda_sg_description"></a> [lambda\_sg\_description](#input\_lambda\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_lambda_sg_name"></a> [lambda\_sg\_name](#input\_lambda\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout value | `number` | n/a | yes |
| <a name="input_layer_version_compatible_architectures"></a> [layer\_version\_compatible\_architectures](#input\_layer\_version\_compatible\_architectures) | List of Architectures this layer is compatible with. Currently x86\_64 and arm64 can be specified | `string` | `"x86_64"` | no |
| <a name="input_layer_version_compatible_runtimes"></a> [layer\_version\_compatible\_runtimes](#input\_layer\_version\_compatible\_runtimes) | A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified | `list(string)` | <pre>[<br>  "python3.11"<br>]</pre> | no |
| <a name="input_layer_version_permission_action"></a> [layer\_version\_permission\_action](#input\_layer\_version\_permission\_action) | Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation | `string` | `"lambda:GetLayerVersion"` | no |
| <a name="input_layer_version_permission_principal"></a> [layer\_version\_permission\_principal](#input\_layer\_version\_permission\_principal) | AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely | `string` | `"*"` | no |
| <a name="input_layer_version_permission_statement_id"></a> [layer\_version\_permission\_statement\_id](#input\_layer\_version\_permission\_statement\_id) | The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for | `string` | `"dev-account"` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_plaintext_secret"></a> [plaintext\_secret](#input\_plaintext\_secret) | Specifies text data that you want to encrypt and store in this version of the secret | `string` | `""` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | `null` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | Whether to publish creation/change as new Lambda Function Version | `bool` | n/a | yes |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `30` | no |
| <a name="input_replica_kms_key_id"></a> [replica\_kms\_key\_id](#input\_replica\_kms\_key\_id) | ARN, Key ID, or Alias | `string` | `null` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | Region for replicating the secret | `string` | `null` | no |
| <a name="input_rotation_after_days"></a> [rotation\_after\_days](#input\_rotation\_after\_days) | A structure that defines the rotation configuration for this secret | `number` | n/a | yes |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | Specifies if rotation is set or not | `bool` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | n/a | yes |
| <a name="input_secrets_manager_token_keyname"></a> [secrets\_manager\_token\_keyname](#input\_secrets\_manager\_token\_keyname) | token key name from secrets manager if you store token as key value pair | `string` | `null` | no |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | `""` | no |
| <a name="input_secretsmanager_name"></a> [secretsmanager\_name](#input\_secretsmanager\_name) | Name of the new secret | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_sonar_host"></a> [sonar\_host](#input\_sonar\_host) | sonarqube host name. | `string` | n/a | yes |
| <a name="input_sonar_token_name_new"></a> [sonar\_token\_name\_new](#input\_sonar\_token\_name\_new) | new sonarqube token name to create on Sonarqube host, should be different from previous token (date will get added to the string you provide) | `string` | n/a | yes |
| <a name="input_source_dir"></a> [source\_dir](#input\_source\_dir) | Package entire contents of this directory into the archive. | `string` | n/a | yes |
| <a name="input_store_as_key_value"></a> [store\_as\_key\_value](#input\_store\_as\_key\_value) | specifies storing secret as plaintext or key value pair | `bool` | `false` | no |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Custom policy filename for the kms | `string` | `""` | no |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |
| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | Date this resource was last modified |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | ARN identifying your Lambda Function Version (if versioning is enabled via publish = true) |
| <a name="output_lambda_signing_job_arn"></a> [lambda\_signing\_job\_arn](#output\_lambda\_signing\_job\_arn) | ARN of the signing job |
| <a name="output_lambda_signing_profile_version_arn"></a> [lambda\_signing\_profile\_version\_arn](#output\_lambda\_signing\_profile\_version\_arn) | ARN of the signing profile version |
| <a name="output_lambda_source_code_size"></a> [lambda\_source\_code\_size](#output\_lambda\_source\_code\_size) | Size in bytes of the function .zip file |
| <a name="output_lambda_tags_all"></a> [lambda\_tags\_all](#output\_lambda\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of your Lambda Function |
| <a name="output_lambda_vpc_config_vpc_id"></a> [lambda\_vpc\_config\_vpc\_id](#output\_lambda\_vpc\_config\_vpc\_id) | ID of the VPC |
| <a name="output_rotation_enabled"></a> [rotation\_enabled](#output\_rotation\_enabled) | Whether automatic rotation is enabled for this secret |
| <a name="output_secrets_manager_arn"></a> [secrets\_manager\_arn](#output\_secrets\_manager\_arn) | ARN of the secret |

<!-- END_TF_DOCS -->
