<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.74.0 |

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
| <a name="module_dashboard"></a> [dashboard](#module\_dashboard) | ../modules/dashboard | n/a |
| <a name="module_trusted_advisor_alarms"></a> [trusted\_advisor\_alarms](#module\_trusted\_advisor\_alarms) | ../modules/trusted_advisor_alarms | n/a |
| <a name="module_usage_alarms_us_east_1"></a> [usage\_alarms\_us\_east\_1](#module\_usage\_alarms\_us\_east\_1) | ../modules/usage_alarms | n/a |
| <a name="module_usage_alarms_us_west_2"></a> [usage\_alarms\_us\_west\_2](#module\_usage\_alarms\_us\_west\_2) | ../modules/usage_alarms | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.inuse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | `"eks-test"` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->