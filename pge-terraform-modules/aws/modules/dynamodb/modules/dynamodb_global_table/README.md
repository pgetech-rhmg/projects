<!-- BEGIN_TF_DOCS -->
# AWS DynamoDb Global Table module for V1 (version 2017.11.29).
To instead manage DynamoDB Global Tables V2 (version 2019.11.21), use the 'dynamodb\_table' module - replica configuration block.
Terraform module which creates SAF2.0 Dynamodb Global tables v1 in AWS in regions: "us-west-2" and "us-east-1" in AWS.
Customer Manged CMK's are not supported in global tables V1.

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
| [aws_dynamodb_global_table.dynamodb_global_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_global_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_replica_region_name"></a> [global\_replica\_region\_name](#input\_global\_replica\_region\_name) | Defines the global replica region for the dynamodb global replica. The Underlying DynamoDB Table. At least 1 replica must be defined.This will be the replica of the primary region. | `string` | n/a | yes |
| <a name="input_primary_aws_region"></a> [primary\_aws\_region](#input\_primary\_aws\_region) | Defines the primary region of the dynamodb table. | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Dynamodb table name (space is not allowed). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_global_table_arn"></a> [dynamodb\_global\_table\_arn](#output\_dynamodb\_global\_table\_arn) | The ARN of the DynamoDB Global Table. |
| <a name="output_dynamodb_global_table_id"></a> [dynamodb\_global\_table\_id](#output\_dynamodb\_global\_table\_id) | The name of the DynamoDB Global Table. |

<!-- END_TF_DOCS -->