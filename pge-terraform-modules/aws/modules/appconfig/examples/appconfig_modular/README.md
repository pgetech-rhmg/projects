<!-- BEGIN_TF_DOCS -->
# AWS AppConfig modular example

#### This example demonstrates a full and modularized AppConfig use case that allows for complete control
over your AppConfig resources.

You may also reference the appconfig\_simple example for a rapid, simple use case that uses a single module
that wraps submodules for a simplified configuration, but more restricted in its use case.

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
| <a name="module_application"></a> [application](#module\_application) | ../../modules/application | n/a |
| <a name="module_configuration_profile"></a> [configuration\_profile](#module\_configuration\_profile) | ../../modules/configuration_profile | n/a |
| <a name="module_deployment"></a> [deployment](#module\_deployment) | ../../modules/deployment | n/a |
| <a name="module_deployment_strategy"></a> [deployment\_strategy](#module\_deployment\_strategy) | ../../modules/deployment_strategy | n/a |
| <a name="module_environment"></a> [environment](#module\_environment) | ../../modules/environment | n/a |
| <a name="module_hosted_configuration_version"></a> [hosted\_configuration\_version](#module\_hosted\_configuration\_version) | ../../modules/hosted_configuration_version | n/a |
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
| <a name="input_bake_time"></a> [bake\_time](#input\_bake\_time) | Amount of time AWS AppConfig monitors for alarms before considering the deployment to be complete and no longer eligble for automatic rollback. | `number` | `0` | no |
| <a name="input_config_profile_desc"></a> [config\_profile\_desc](#input\_config\_profile\_desc) | The description of the AppConfig configuration profile. | `string` | n/a | yes |
| <a name="input_config_profile_name"></a> [config\_profile\_name](#input\_config\_profile\_name) | The name of the AppConfig configuration profile. | `string` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | Content of the configuration or the configuration data. | `string` | n/a | yes |
| <a name="input_deployment_duration"></a> [deployment\_duration](#input\_deployment\_duration) | Total amount of time for a deployment to last. | `number` | `0` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the AppConfig application. | `string` | `null` | no |
| <a name="input_env_description"></a> [env\_description](#input\_env\_description) | A description of the environment. | `string` | `null` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The name of the environment | `string` | n/a | yes |
| <a name="input_growth_factor"></a> [growth\_factor](#input\_growth\_factor) | Percentage of targets to receive a deployed configuration during each interval. | `number` | `1` | no |
| <a name="input_growth_type"></a> [growth\_type](#input\_growth\_type) | Algorithm used to define how percentage grows over time. | `string` | `"LINEAR"` | no |
| <a name="input_hosted_config_description"></a> [hosted\_config\_description](#input\_hosted\_config\_description) | A description of the configuration. | `string` | `null` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | KMS key name for S3 bucket encryption | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_monitors"></a> [monitors](#input\_monitors) | A set of CloudWatch alarms to monitor during the deployment process. | `set(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AppConfig application. | `string` | `""` | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_replicate_to"></a> [replicate\_to](#input\_replicate\_to) | Where to save the deployment strategy. | `string` | `"NONE"` | no |
| <a name="input_strategy_description"></a> [strategy\_description](#input\_strategy\_description) | Description of the deployment strategy | `string` | `null` | no |
| <a name="input_strategy_name"></a> [strategy\_name](#input\_strategy\_name) | Name for the deployment strategy. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The AppConfig application ID |
| <a name="output_configuration_profile_id"></a> [configuration\_profile\_id](#output\_configuration\_profile\_id) | The AppConfig configuration profile ID |
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | The AppConfig application ID, environment ID, and deployment number separated by a slash |
| <a name="output_deployment_strategy_id"></a> [deployment\_strategy\_id](#output\_deployment\_strategy\_id) | The AppConfig deployment strategy ID |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The AppConfig environment ID |

<!-- END_TF_DOCS -->