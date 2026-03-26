<!-- BEGIN_TF_DOCS -->
# AWS Lambda trigger module
Composite module using SAF2.0 CCOE modules

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

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
| <a name="module_lambda_event_source_mapping_sqs"></a> [lambda\_event\_source\_mapping\_sqs](#module\_lambda\_event\_source\_mapping\_sqs) | app.terraform.io/pgetech/lambda/aws//modules/event_source_mapping_sqs | 0.0.15 |
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-ecs/aws | ~> 1.0 |
| <a name="module_sns_subscription"></a> [sns\_subscription](#module\_sns\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.0.15 |
| <a name="module_sqs_queue"></a> [sqs\_queue](#module\_sqs\_queue) | app.terraform.io/pgetech/sqs/aws//modules/sqs_standard_queue | 0.0.11 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sqs_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The AWS KMS to use in SQS | `string` | `"alias/aws/sqs"` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of the particular AWS Lambda | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS Topic for the SQS queue | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The list of PG&E tags required for AWS assets | `map(any)` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->