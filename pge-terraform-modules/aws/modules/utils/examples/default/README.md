<!-- BEGIN_TF_DOCS -->


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
| <a name="module_linux_ami_id"></a> [linux\_ami\_id](#module\_linux\_ami\_id) | ../../modules/golden-ami/ | n/a |
| <a name="module_ssm_appid"></a> [ssm\_appid](#module\_ssm\_appid) | ../../modules/ssm | n/a |
| <a name="module_ssm_nacl"></a> [ssm\_nacl](#module\_ssm\_nacl) | ../../modules/ssm | n/a |
| <a name="module_ssm_rtbl"></a> [ssm\_rtbl](#module\_ssm\_rtbl) | ../../modules/ssm | n/a |
| <a name="module_subnet1_cidr"></a> [subnet1\_cidr](#module\_subnet1\_cidr) | ../../modules/subnet | n/a |
| <a name="module_subnet1_id"></a> [subnet1\_id](#module\_subnet1\_id) | ../../modules/subnet | n/a |
| <a name="module_subnet2_cidr"></a> [subnet2\_cidr](#module\_subnet2\_cidr) | ../../modules/subnet | n/a |
| <a name="module_subnet2_id"></a> [subnet2\_id](#module\_subnet2\_id) | ../../modules/subnet | n/a |
| <a name="module_vpcid"></a> [vpcid](#module\_vpcid) | ../../modules/vpcid/ | n/a |
| <a name="module_windows_ami_id"></a> [windows\_ami\_id](#module\_windows\_ami\_id) | ../../modules/golden-ami/ | n/a |
| <a name="module_windows_security_groups"></a> [windows\_security\_groups](#module\_windows\_security\_groups) | ../../modules/windows-security-groups | n/a |
| <a name="module_ws"></a> [ws](#module\_ws) | ../../modules/workspace-info | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | workspace id | `string` | `null` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | workspace name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linux_ami_id"></a> [linux\_ami\_id](#output\_linux\_ami\_id) | n/a |
| <a name="output_ssm_appid"></a> [ssm\_appid](#output\_ssm\_appid) | n/a |
| <a name="output_ssm_nacl"></a> [ssm\_nacl](#output\_ssm\_nacl) | n/a |
| <a name="output_ssm_rtbl"></a> [ssm\_rtbl](#output\_ssm\_rtbl) | n/a |
| <a name="output_subnet1_cidr"></a> [subnet1\_cidr](#output\_subnet1\_cidr) | n/a |
| <a name="output_subnet1_id"></a> [subnet1\_id](#output\_subnet1\_id) | n/a |
| <a name="output_subnet2_cidr"></a> [subnet2\_cidr](#output\_subnet2\_cidr) | n/a |
| <a name="output_subnet2_id"></a> [subnet2\_id](#output\_subnet2\_id) | n/a |
| <a name="output_vpcid"></a> [vpcid](#output\_vpcid) | output |
| <a name="output_windows_ami_id"></a> [windows\_ami\_id](#output\_windows\_ami\_id) | n/a |
| <a name="output_windows_security_groups"></a> [windows\_security\_groups](#output\_windows\_security\_groups) | n/a |
| <a name="output_ws_all"></a> [ws\_all](#output\_ws\_all) | n/a |
| <a name="output_ws_id"></a> [ws\_id](#output\_ws\_id) | n/a |
| <a name="output_ws_name"></a> [ws\_name](#output\_ws\_name) | n/a |


<!-- END_TF_DOCS -->