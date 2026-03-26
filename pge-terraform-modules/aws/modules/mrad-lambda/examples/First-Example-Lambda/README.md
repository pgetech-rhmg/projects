<!-- BEGIN_TF_DOCS -->
# MRAD Example Lambda function with S3 Bucket

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

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
| <a name="module_first_lambda"></a> [first\_lambda](#module\_first\_lambda) | ../../modules/lambda-sumo | n/a |
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |
| <a name="module_second_lambda"></a> [second\_lambda](#module\_second\_lambda) | ../../modules/lambda-sumo | n/a |
| <a name="module_sqs-test_dlq"></a> [sqs-test\_dlq](#module\_sqs-test\_dlq) | ../../../sqs/modules/sqs_standard_queue | n/a |

## Resources

| Name | Type |
|------|------|
| [random_bytes.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/bytes) | resource |
| [aws_secretsmanager_secret_version.sumo_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | n/a | `string` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | n/a | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | n/a | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | n/a | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | n/a | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | n/a | `list(string)` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | n/a | `list(string)` | n/a | yes |
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | n/a | `string` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_archive_path"></a> [archive\_path](#input\_archive\_path) | The path to the Lambda for the archive provider | `string` | `""` | no |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Aws account name, dev, qa, test, production. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | partner team name | `string` | `"MRAD"` | no |
| <a name="input_service"></a> [service](#input\_service) | n/a | `list(string)` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->