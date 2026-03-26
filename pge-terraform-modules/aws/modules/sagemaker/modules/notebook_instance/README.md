<!-- BEGIN_TF_DOCS -->
# AWS sagemaker notebook instnace module
# Terraform module which creates Sagemaker notebook instnace

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |
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
| [aws_sagemaker_notebook_instance.ni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_code_repositories"></a> [additional\_code\_repositories](#input\_additional\_code\_repositories) | An array of up to three Git repositories to associate with the notebook instance. These can be either the names of Git repositories stored as resources in your account, or the URL of Git repositories in AWS CodeCommit or in any other Git repository. These repositories are cloned at the same level as the default repository of your notebook instance. | `list(string)` | `[]` | no |
| <a name="input_default_code_repository"></a> [default\_code\_repository](#input\_default\_code\_repository) | The Git repository associated with the notebook instance as its default code repository. This can be either the name of a Git repository stored as a resource in your account, or the URL of a Git repository in AWS CodeCommit or in any other Git repository. | `string` | `null` | no |
| <a name="input_direct_internet_access"></a> [direct\_internet\_access](#input\_direct\_internet\_access) | Set to Disabled to disable internet access to notebook. Requires security\_groups and subnet\_id to be set. Supported values: Enabled (Default) or Disabled. If set to Disabled, the notebook instance will be able to access resources only in your VPC, and will not be able to connect to Amazon SageMaker training and endpoint services unless your configure a NAT Gateway in your VPC. | `string` | `"Disabled"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the notebook instance (must be unique). | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The name of ML compute instance type. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS Key Management Service (AWS KMS) key that Amazon SageMaker uses to encrypt the model artifacts at rest using Amazon S3 server-side encryption. | `string` | n/a | yes |
| <a name="input_lifecycle_config_name"></a> [lifecycle\_config\_name](#input\_lifecycle\_config\_name) | The name of a lifecycle configuration to associate with the notebook instance. | `string` | `null` | no |
| <a name="input_metadata_service_version"></a> [metadata\_service\_version](#input\_metadata\_service\_version) | Indicates the minimum IMDS version that the notebook instance supports. When passed 1 is passed. This means that both IMDSv1 and IMDSv2 are supported. Valid values are 1 and 2. | `number` | `1` | no |
| <a name="input_platform_identifier"></a> [platform\_identifier](#input\_platform\_identifier) | The platform identifier of the notebook instance runtime environment. This value can be either notebook-al1-v1, notebook-al2-v1, notebook-al2-v2 or notebook-al2-v3, depending on which version of Amazon Linux you require. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The ARN of the IAM role to be used by the notebook instance which allows SageMaker to call other services on your behalf. | `string` | n/a | yes |
| <a name="input_root_access"></a> [root\_access](#input\_root\_access) | Whether root access is Enabled or Disabled for users of the notebook instance. The default value is Enabled. | `string` | `"Disabled"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The associated security groups. | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC subnet ID. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size, in GB, of the ML storage volume to attach to the notebook instance. The default value is 5 GB. | `number` | `5` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notebook_arn"></a> [notebook\_arn](#output\_notebook\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this notebook instance. |
| <a name="output_notebook_id"></a> [notebook\_id](#output\_notebook\_id) | The name of the notebook instance. |
| <a name="output_notebook_interface_id"></a> [notebook\_interface\_id](#output\_notebook\_interface\_id) | The network interface ID that Amazon SageMaker created at the time of creating the instance. Only available when setting subnet\_id. |
| <a name="output_notebook_url"></a> [notebook\_url](#output\_notebook\_url) | The URL that you use to connect to the Jupyter notebook that is running in your notebook instance. |
| <a name="output_sagemaker_notebook_instance_all"></a> [sagemaker\_notebook\_instance\_all](#output\_sagemaker\_notebook\_instance\_all) | A map of aws sagemaker notebook instance |

<!-- END_TF_DOCS -->