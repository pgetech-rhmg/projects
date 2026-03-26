<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |

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
| <a name="module_validate-tags"></a> [validate-tags](#module\_validate-tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.sumo_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID. Format = APP-#### | `number` | `1795` | no |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score | `string` | `"Medium"` | no |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Identify assets with compliance requirements (SOX, HIPAA, NERC etc.) | `list(string)` | <pre>[<br/>  "None"<br/>]</pre> | no |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance 7 | `string` | `"Internal"` | no |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod | `string` | `"development"` | no |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance.  Should be a group or list of email addresses. | `list(string)` | <pre>[<br/>  "MRAD@pge.com"<br/>]</pre> | no |
| <a name="input_Order"></a> [Order](#input\_Order) | 7 or 8 digit order number for FinOps. See https://wiki.comp.pge.com/display/SW/MRAD+FinOps+Order+Numbers | `string` | `"8193198"` | no |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead. Note: separated by underscore giving WAF tagging limitations | `list(string)` | <pre>[<br/>  "A1P2_S2RB_JVCW"<br/>]</pre> | no |
| <a name="input_TFC_CONFIGURATION_VERSION_GIT_BRANCH"></a> [TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH](#input\_TFC\_CONFIGURATION\_VERSION\_GIT\_BRANCH) | The name of the branch that the associated Terraform configuration version was ingressed from - predefined in TFC. See https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment | `string` | `null` | no |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number - predefined in TFC | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume - predefined in TFC | `string` | n/a | yes |
| <a name="input_github_secret"></a> [github\_secret](#input\_github\_secret) | ASM secret name for GitHub token | `string` | `"MRAD_GITHUB_TOKEN"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags"></a> [tags](#output\_tags) | List of all required AWS tags and values |

<!-- END_TF_DOCS -->