<!-- BEGIN_TF_DOCS -->
# AWS Elastic Container Registry module
Terraform module which creates SAF2.0 ECR in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |

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
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_replication_configuration.replication_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.repository_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecr_name"></a> [ecr\_name](#input\_ecr\_name) | Name of the repository. | `string` | n/a | yes |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. | `string` | `"MUTABLE"` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The ARN of the KMS key | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | The policy document for lifecycle policy. | `string` | `"{}"` | no |
| <a name="input_lifecycle_policy_enable"></a> [lifecycle\_policy\_enable](#input\_lifecycle\_policy\_enable) | Enable or disable lifecycle policy. | `bool` | `false` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Valid JSON document representing a resource policy | `any` | `"{}"` | no |
| <a name="input_replication_configuration_enable"></a> [replication\_configuration\_enable](#input\_replication\_configuration\_enable) | Enable or disable replication configuration for a registry. | `bool` | `false` | no |
| <a name="input_replication_configuration_filter"></a> [replication\_configuration\_filter](#input\_replication\_configuration\_filter) | The repository filter details. | `string` | `null` | no |
| <a name="input_replication_configuration_filter_type"></a> [replication\_configuration\_filter\_type](#input\_replication\_configuration\_filter\_type) | The repository filter type. | `string` | `null` | no |
| <a name="input_replication_configuration_region"></a> [replication\_configuration\_region](#input\_replication\_configuration\_region) | A Region to replicate. | `string` | `null` | no |
| <a name="input_replication_configuration_registry_id"></a> [replication\_configuration\_registry\_id](#input\_replication\_configuration\_registry\_id) | The account ID of the destination registry to replicate. | `string` | `null` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_all"></a> [ecr\_all](#output\_ecr\_all) | All attributes of ECR repository |
| <a name="output_ecr_arn"></a> [ecr\_arn](#output\_ecr\_arn) | Full ARN of the repository. |
| <a name="output_ecr_registry_id"></a> [ecr\_registry\_id](#output\_ecr\_registry\_id) | The registry ID where the repository was created. |
| <a name="output_ecr_repository_name_lifecycle_policy"></a> [ecr\_repository\_name\_lifecycle\_policy](#output\_ecr\_repository\_name\_lifecycle\_policy) | The name of the repository. |
| <a name="output_ecr_repository_name_repository_policy"></a> [ecr\_repository\_name\_repository\_policy](#output\_ecr\_repository\_name\_repository\_policy) | The name of the repository. |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the repository. |
| <a name="output_ecr_tags_all"></a> [ecr\_tags\_all](#output\_ecr\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->