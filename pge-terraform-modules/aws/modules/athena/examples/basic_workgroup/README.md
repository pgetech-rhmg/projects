<!-- BEGIN_TF_DOCS -->
Athena Basic Workgroup Example

Description:
  Demonstrates standalone deployment of the Athena
  workgroup module without Glue integration.

  This example provisions:
    - S3 bucket for Athena query results
    - Athena workgroup

  Intended to show the minimal, composable usage
  pattern of the base Athena module.

Example Path:
  aws/modules/athena/examples/basic\_workgroup

Author:
  PG&E Cloud Engineering

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_athena"></a> [athena](#module\_athena) | ../../ | n/a |
| <a name="module_s3_results"></a> [s3\_results](#module\_s3\_results) | app.terraform.io/pgetech/s3/aws | 0.1.3 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Application ID tag used for resource identification. | `string` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | CRIS identifier used for compliance, governance, and tracking. | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance frameworks or standards applicable to this resource. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification level applied for compliance and governance. | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment tag indicating deployment stage (e.g., Dev, QA, Prod). | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | List of email addresses or contacts to notify for resource events. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order or priority tag used for resource grouping and sorting. | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List of owners responsible for the lifecycle of this resource. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_athena_workgroup_name"></a> [athena\_workgroup\_name](#input\_athena\_workgroup\_name) | Name of the Athena Workgroup to be created. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be deployed. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | IAM role name used for assuming into the target AWS account. | `string` | n/a | yes |
| <a name="input_results_bucket_name"></a> [results\_bucket\_name](#input\_results\_bucket\_name) | Name of the S3 bucket used to store Athena query results. | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->