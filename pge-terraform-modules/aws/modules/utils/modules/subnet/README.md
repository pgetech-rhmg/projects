<!-- BEGIN_TF_DOCS -->
# PG&E subnet utils sub module
 Terraform module to get the subnet id or cidr from the parameter store

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
| [aws_ssm_parameter.subnet_id_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_cidr"></a> [is\_cidr](#input\_is\_cidr) | set to true if cidr is to be read | `bool` | `false` | no |
| <a name="input_subnet_num"></a> [subnet\_num](#input\_subnet\_num) | subnet number for which id or cidr is requested | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id_cidr"></a> [subnet\_id\_cidr](#output\_subnet\_id\_cidr) | subnet id or cidr |


<!-- END_TF_DOCS -->