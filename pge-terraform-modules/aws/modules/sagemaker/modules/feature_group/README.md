<!-- BEGIN_TF_DOCS -->
# AWS sagemaker feature group module.
Terraform module which creates SAF2.0 Sagemaker feature group in AWS.

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
| [aws_sagemaker_feature_group.feature_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_feature_group) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A free-form description of a Feature Group. | `string` | `null` | no |
| <a name="input_feature_definition"></a> [feature\_definition](#input\_feature\_definition) | A list of Feature names and types. See Feature Definition Below. | `list(any)` | `[]` | no |
| <a name="input_feature_group_name"></a> [feature\_group\_name](#input\_feature\_group\_name) | The name of the Feature Group. The name must be unique within an AWS Region in an AWS account. | `string` | n/a | yes |
| <a name="input_feature_name"></a> [feature\_name](#input\_feature\_name) | record\_identifier\_feature\_name:<br/> The name of the Feature whose value uniquely identifies a Record defined in the Feature Store. Only the latest record per identifier value will be stored in the Online Store<br/>event\_time\_feature\_name:<br/> The name of the feature that stores the EventTime of a Record in a Feature Group. | <pre>object({<br/>    record_identifier_feature_name = string<br/>    event_time_feature_name        = string<br/><br/>  })</pre> | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The Amazon Key Management Service (KMS) key ARN for server-side encryption. | `string` | n/a | yes |
| <a name="input_offline_store_config"></a> [offline\_store\_config](#input\_offline\_store\_config) | The Offline Feature Store Configuration. See Offline Store Config Below. | `any` | `null` | no |
| <a name="input_online_store_config"></a> [online\_store\_config](#input\_online\_store\_config) | The Online Feature Store Configuration. See Online Store Config Below. | `any` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The Amazon Resource Name (ARN) of the IAM execution role used to persist data into the Offline Store if an offline\_store\_config is provided. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this feature\_group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Feature Group. |
| <a name="output_sagemaker_feature_group_all"></a> [sagemaker\_feature\_group\_all](#output\_sagemaker\_feature\_group\_all) | A map of aws sagemaker feature group |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->