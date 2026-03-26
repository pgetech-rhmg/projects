<!-- BEGIN_TF_DOCS -->
# AWS sagemaker endpoint\_configuration module
# Terraform module which creates Sagemaker endpoint\_configuration

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
| [aws_sagemaker_endpoint_configuration.ec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint_configuration) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerator_type"></a> [accelerator\_type](#input\_accelerator\_type) | The size of the Elastic Inference (EI) instance to use for the production variant. | `string` | `null` | no |
| <a name="input_async_inference_config"></a> [async\_inference\_config](#input\_async\_inference\_config) | Specifies configuration for how an endpoint performs asynchronous inference. This is a required field in order for your Endpoint to be invoked. | `any` | `null` | no |
| <a name="input_data_capture_config"></a> [data\_capture\_config](#input\_data\_capture\_config) | Specifies the parameters to capture input/output of SageMaker models endpoints. | `any` | `null` | no |
| <a name="input_initial_instance_count"></a> [initial\_instance\_count](#input\_initial\_instance\_count) | Initial number of instances used for auto-scaling. | `number` | `null` | no |
| <a name="input_initial_variant_weight"></a> [initial\_variant\_weight](#input\_initial\_variant\_weight) | Determines initial traffic distribution among all of the models that you specify in the endpoint configuration. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint. | `string` | `null` | no |
| <a name="input_model_name"></a> [model\_name](#input\_model\_name) | The name of the model to use. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the endpoint configuration. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_serverless_config"></a> [serverless\_config](#input\_serverless\_config) | Specifies configuration for how an endpoint performs asynchronous inference. | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_variant_name"></a> [variant\_name](#input\_variant\_name) | The name of the variant. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_config_arn"></a> [endpoint\_config\_arn](#output\_endpoint\_config\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this endpoint configuration. |
| <a name="output_endpoint_config_name"></a> [endpoint\_config\_name](#output\_endpoint\_config\_name) | The name of the endpoint configuration. |
| <a name="output_endpoint_config_tags"></a> [endpoint\_config\_tags](#output\_endpoint\_config\_tags) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_sagemaker_endpoint_configuration_all"></a> [sagemaker\_endpoint\_configuration\_all](#output\_sagemaker\_endpoint\_configuration\_all) | A map of aws sagemaker endpoint configuration |

<!-- END_TF_DOCS -->