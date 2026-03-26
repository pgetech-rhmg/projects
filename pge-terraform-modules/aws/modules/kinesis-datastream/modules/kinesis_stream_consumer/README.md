<!-- BEGIN_TF_DOCS -->
*#AWS Kinesis data stream module
*Terraform module which creates kinesis stream consumer

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kinesis_stream_consumer.kinesis_stream_consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream_consumer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the stream consumer. | `string` | n/a | yes |
| <a name="input_stream_arn"></a> [stream\_arn](#input\_stream\_arn) | Amazon Resource Name (ARN) of the data stream the consumer is registered with. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the stream consumer. |
| <a name="output_creation_timestamp"></a> [creation\_timestamp](#output\_creation\_timestamp) | Approximate timestamp in RFC3339 format of when the stream consumer was created. |
| <a name="output_id"></a> [id](#output\_id) | Amazon Resource Name (ARN) of the stream consumer. |
| <a name="output_kinesis_stream_consumer_all"></a> [kinesis\_stream\_consumer\_all](#output\_kinesis\_stream\_consumer\_all) | A map of kinesis\_stream\_consumer attributes |

<!-- END_TF_DOCS -->