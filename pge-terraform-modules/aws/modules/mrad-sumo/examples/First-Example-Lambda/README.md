<!-- BEGIN_TF_DOCS -->
# MRAD Example Lambda function with Sumo integration

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.0.0 |

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
| <a name="module_first_lambda"></a> [first\_lambda](#module\_first\_lambda) | app.terraform.io/pgetech/mrad-lambda/aws//modules/lambda | ~> 3.0 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |
| <a name="module_sumo_logger"></a> [sumo\_logger](#module\_sumo\_logger) | ../../../mrad-sumo | n/a |

## Resources

No resources.

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
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | The name of the Lambda | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | partner team name | `string` | `"MRAD"` | no |
| <a name="input_service"></a> [service](#input\_service) | n/a | `list(string)` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->