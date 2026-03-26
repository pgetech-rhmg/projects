<!-- BEGIN_TF_DOCS -->
# AWS  Elastic Beanstalk User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

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
| <a name="module_acm"></a> [acm](#module\_acm) | app.terraform.io/pgetech/acm/aws//modules/acm_import_certificate | 0.1.2 |
| <a name="module_configuration_template"></a> [configuration\_template](#module\_configuration\_template) | ../../modules/configuration_template | n/a |
| <a name="module_elastic_beanstalk_application"></a> [elastic\_beanstalk\_application](#module\_elastic\_beanstalk\_application) | ../../ | n/a |
| <a name="module_elastic_beanstalk_application_version"></a> [elastic\_beanstalk\_application\_version](#module\_elastic\_beanstalk\_application\_version) | ../../modules/elastic_beanstalk_application_version | n/a |
| <a name="module_elastic_beanstalk_environment"></a> [elastic\_beanstalk\_environment](#module\_elastic\_beanstalk\_environment) | ../../modules/environment | n/a |
| <a name="module_elastic_beanstalk_iam_role"></a> [elastic\_beanstalk\_iam\_role](#module\_elastic\_beanstalk\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_kms"></a> [kms](#module\_kms) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_s3_for_logs"></a> [s3\_for\_logs](#module\_s3\_for\_logs) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.elastic_beanstalk_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_s3_object.s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [tls_private_key.private_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_self_signed_cert.self_signed_cert](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/self_signed_cert) | resource |
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
| <a name="input_acm_domain_name"></a> [acm\_domain\_name](#input\_acm\_domain\_name) | Domain name for which the certificate should be issued. | `string` | n/a | yes |
| <a name="input_allowed_uses"></a> [allowed\_uses](#input\_allowed\_uses) | List of key usages allowed for the issued certificate. | `list(string)` | n/a | yes |
| <a name="input_application_version"></a> [application\_version](#input\_application\_version) | Application version deployed. | `string` | n/a | yes |
| <a name="input_application_version_force_delete"></a> [application\_version\_force\_delete](#input\_application\_version\_force\_delete) | On delete, force an Application Version to be deleted when it may be in use by multiple Elastic Beanstalk Environments. | `bool` | n/a | yes |
| <a name="input_application_version_source_zip"></a> [application\_version\_source\_zip](#input\_application\_version\_source\_zip) | Application version source zip file path/name. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | `[]` | no |
| <a name="input_environment_solution_stack_name"></a> [environment\_solution\_stack\_name](#input\_environment\_solution\_stack\_name) | Elastic Beanstalk environment solution stack name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | the organisation of thr acm | `string` | n/a | yes |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies arns to attach to the IAM role | `list(string)` | n/a | yes |
| <a name="input_private_key_algorithm"></a> [private\_key\_algorithm](#input\_private\_key\_algorithm) | Name of the algorithm to use when generating the private key. Currently-supported values are: RSA, ECDSA, ED25519. | `string` | n/a | yes |
| <a name="input_solution_stack_name"></a> [solution\_stack\_name](#input\_solution\_stack\_name) | A solution stack to base your Template off of. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | Value of subnet id1 stored in ssm parameter. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | Value of subnet id2 stored in ssm parameter. | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | Value of subnet id3 stored in ssm parameter. | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | Value of vpc id stored in ssm parameter. | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | n/a | yes |
| <a name="input_validity_period_hours"></a> [validity\_period\_hours](#input\_validity\_period\_hours) | The validity hours of the acm certificate | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_version_arn"></a> [application\_version\_arn](#output\_application\_version\_arn) | ARN assigned by AWS for this Elastic Beanstalk Application. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS for this Elastic Beanstalk Application. |
| <a name="output_environment_all_settings"></a> [environment\_all\_settings](#output\_environment\_all\_settings) | List of all option settings configured in this Environment. |
| <a name="output_environment_application"></a> [environment\_application](#output\_environment\_application) | The Elastic Beanstalk Application specified for this environment. |
| <a name="output_environment_autoscaling_groups"></a> [environment\_autoscaling\_groups](#output\_environment\_autoscaling\_groups) | The autoscaling groups used by this Environment. |
| <a name="output_environment_cname"></a> [environment\_cname](#output\_environment\_cname) | Fully qualified DNS name for this Environment. |
| <a name="output_environment_description"></a> [environment\_description](#output\_environment\_description) | Description of the Elastic Beanstalk Environment. |
| <a name="output_environment_endpoint_url"></a> [environment\_endpoint\_url](#output\_environment\_endpoint\_url) | The URL to the Load Balancer for this Environment |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | ID of the Elastic Beanstalk Environment. |
| <a name="output_environment_instances"></a> [environment\_instances](#output\_environment\_instances) | Instances used by this Environment. |
| <a name="output_environment_launch_configurations"></a> [environment\_launch\_configurations](#output\_environment\_launch\_configurations) | Launch configurations in use by this Environment. |
| <a name="output_environment_load_balancers"></a> [environment\_load\_balancers](#output\_environment\_load\_balancers) | Elastic load balancers in use by this Environment. |
| <a name="output_environment_name"></a> [environment\_name](#output\_environment\_name) | Name of the Elastic Beanstalk Environment. |
| <a name="output_environment_queues"></a> [environment\_queues](#output\_environment\_queues) | SQS queues in use by this Environment. |
| <a name="output_environment_setting"></a> [environment\_setting](#output\_environment\_setting) | Settings specifically set for this Environment. |
| <a name="output_environment_tags_all"></a> [environment\_tags\_all](#output\_environment\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_environment_tier"></a> [environment\_tier](#output\_environment\_tier) | The environment tier specified. |
| <a name="output_environment_triggers"></a> [environment\_triggers](#output\_environment\_triggers) | Autoscaling triggers in use by this Environment. |
| <a name="output_name"></a> [name](#output\_name) | elastic beanstalk application name. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_template_application"></a> [template\_application](#output\_template\_application) | Name of the application to associate with this configuration template. |
| <a name="output_template_description"></a> [template\_description](#output\_template\_description) | Description of the template. |
| <a name="output_template_environment_id"></a> [template\_environment\_id](#output\_template\_environment\_id) | The ID of the environment used with this configuration template. |
| <a name="output_template_name"></a> [template\_name](#output\_template\_name) | The name of the template. |
| <a name="output_template_solution_stack_name"></a> [template\_solution\_stack\_name](#output\_template\_solution\_stack\_name) | Name of the solution stack. |


<!-- END_TF_DOCS -->