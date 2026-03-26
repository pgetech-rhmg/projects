<!-- BEGIN_TF_DOCS -->
# AWS DynamoDb Kinesis Streaming destination module
Terraform module which enables Kinesis streaming destination for data replication of SAF 2.0 Dynamodb table in AWS.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_kinesis_streaming_destination.dynamodb_kinesis_streaming_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_kinesis_streaming_destination) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_stream_arn"></a> [stream\_arn](#input\_stream\_arn) | The ARN for a Kinesis data stream. This must exist in the same account and region as the DynamoDB table. | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Dynamodb table name (space is not allowed). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kinesis_id"></a> [kinesis\_id](#output\_kinesis\_id) | The table\_name and stream\_arn separated by a comma (,). |

<!-- END_TF_DOCS -->