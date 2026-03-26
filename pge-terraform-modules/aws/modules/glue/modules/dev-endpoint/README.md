<!-- BEGIN_TF_DOCS -->
# AWS Glue Dev Endpoint module.
Terraform module which creates SAF2.0 Glue Dev Endpoint in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

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
| [aws_glue_dev_endpoint.glue_dev_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_dev_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dev_endpoint"></a> [dev\_endpoint](#input\_dev\_endpoint) | worker\_type:<br> The type of predefined worker that is allocated to this endpoint. Accepts a value of Standard, G.1X, or G.2X.<br>number\_of\_workers:<br> The number of workers of a defined worker type that are allocated to this endpoint. This field is available only when you choose worker type G.1X or G.2X.<br>number\_of\_nodes:<br> The number of AWS Glue Data Processing Units (DPUs) to allocate to this endpoint. Conflicts with worker\_type. | <pre>object({<br>    worker_type       = string<br>    number_of_workers = number<br>    number_of_nodes   = number<br>  })</pre> | <pre>{<br>  "number_of_nodes": null,<br>  "number_of_workers": null,<br>  "worker_type": null<br>}</pre> | no |
| <a name="input_glue_dev_endpoint_arguments"></a> [glue\_dev\_endpoint\_arguments](#input\_glue\_dev\_endpoint\_arguments) | A map of arguments used to configure the endpoint. | `map(string)` | `{}` | no |
| <a name="input_glue_dev_endpoint_extra_jars_s3_path"></a> [glue\_dev\_endpoint\_extra\_jars\_s3\_path](#input\_glue\_dev\_endpoint\_extra\_jars\_s3\_path) | Path to one or more Java Jars in an S3 bucket that should be loaded in this endpoint. | `string` | `null` | no |
| <a name="input_glue_dev_endpoint_extra_python_libs_s3_path"></a> [glue\_dev\_endpoint\_extra\_python\_libs\_s3\_path](#input\_glue\_dev\_endpoint\_extra\_python\_libs\_s3\_path) | Path(s) to one or more Python libraries in an S3 bucket that should be loaded in this endpoint. Multiple values must be complete paths separated by a comma. | `string` | `null` | no |
| <a name="input_glue_dev_endpoint_glue_version"></a> [glue\_dev\_endpoint\_glue\_version](#input\_glue\_dev\_endpoint\_glue\_version) | Specifies the versions of Python and Apache Spark to use. Defaults to AWS Glue version 0.9. | `string` | `null` | no |
| <a name="input_glue_dev_endpoint_name"></a> [glue\_dev\_endpoint\_name](#input\_glue\_dev\_endpoint\_name) | The name of this endpoint. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_public_key"></a> [glue\_dev\_endpoint\_public\_key](#input\_glue\_dev\_endpoint\_public\_key) | The public key to be used by this endpoint for authentication. | `string` | `null` | no |
| <a name="input_glue_dev_endpoint_public_keys"></a> [glue\_dev\_endpoint\_public\_keys](#input\_glue\_dev\_endpoint\_public\_keys) | A list of public keys to be used by this endpoint for authentication. | `list(string)` | `[]` | no |
| <a name="input_glue_dev_endpoint_role_arn"></a> [glue\_dev\_endpoint\_role\_arn](#input\_glue\_dev\_endpoint\_role\_arn) | The IAM role for this endpoint. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_security_configuration"></a> [glue\_dev\_endpoint\_security\_configuration](#input\_glue\_dev\_endpoint\_security\_configuration) | The name of the Security Configuration structure to be used with this endpoint. | `string` | n/a | yes |
| <a name="input_glue_dev_endpoint_security_group_ids"></a> [glue\_dev\_endpoint\_security\_group\_ids](#input\_glue\_dev\_endpoint\_security\_group\_ids) | Security group IDs for the security groups to be used by this endpoint. | `list(string)` | `[]` | no |
| <a name="input_glue_dev_endpoint_subnet_id"></a> [glue\_dev\_endpoint\_subnet\_id](#input\_glue\_dev\_endpoint\_subnet\_id) | The subnet ID for the new endpoint to use. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_dev_endpoint"></a> [aws\_glue\_dev\_endpoint](#output\_aws\_glue\_dev\_endpoint) | The map of aws\_glue\_dev\_endpoint. |
| <a name="output_glue_dev_endpoint_arn"></a> [glue\_dev\_endpoint\_arn](#output\_glue\_dev\_endpoint\_arn) | The ARN of the endpoint. |
| <a name="output_glue_dev_endpoint_availability_zone"></a> [glue\_dev\_endpoint\_availability\_zone](#output\_glue\_dev\_endpoint\_availability\_zone) | The AWS availability zone where this endpoint is located. |
| <a name="output_glue_dev_endpoint_failure_reason"></a> [glue\_dev\_endpoint\_failure\_reason](#output\_glue\_dev\_endpoint\_failure\_reason) | The reason for a current failure in this endpoint. |
| <a name="output_glue_dev_endpoint_name"></a> [glue\_dev\_endpoint\_name](#output\_glue\_dev\_endpoint\_name) | The name of the new endpoint. |
| <a name="output_glue_dev_endpoint_private_address"></a> [glue\_dev\_endpoint\_private\_address](#output\_glue\_dev\_endpoint\_private\_address) | A private IP address to access the endpoint within a VPC, if this endpoint is created within one. |
| <a name="output_glue_dev_endpoint_public_address"></a> [glue\_dev\_endpoint\_public\_address](#output\_glue\_dev\_endpoint\_public\_address) | The public IP address used by this endpoint. The PublicAddress field is present only when you create a non-VPC endpoint. |
| <a name="output_glue_dev_endpoint_status"></a> [glue\_dev\_endpoint\_status](#output\_glue\_dev\_endpoint\_status) | The current status of this endpoint. |
| <a name="output_glue_dev_endpoint_tags_all"></a> [glue\_dev\_endpoint\_tags\_all](#output\_glue\_dev\_endpoint\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_glue_dev_endpoint_vpc_id"></a> [glue\_dev\_endpoint\_vpc\_id](#output\_glue\_dev\_endpoint\_vpc\_id) | The ID of the VPC used by this endpoint. |
| <a name="output_glue_dev_endpoint_yarn_endpoint_address"></a> [glue\_dev\_endpoint\_yarn\_endpoint\_address](#output\_glue\_dev\_endpoint\_yarn\_endpoint\_address) | The YARN endpoint address used by this endpoint. |
| <a name="output_glue_dev_endpoint_zeppelin_remote_spark_interpreter_port"></a> [glue\_dev\_endpoint\_zeppelin\_remote\_spark\_interpreter\_port](#output\_glue\_dev\_endpoint\_zeppelin\_remote\_spark\_interpreter\_port) | The Apache Zeppelin port for the remote Apache Spark interpreter. |


<!-- END_TF_DOCS -->