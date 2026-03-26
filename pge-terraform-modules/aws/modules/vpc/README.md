<!-- BEGIN_TF_DOCS -->
# AWS vpc secondary cidr module
Terraform module which creates SAF2.0 VPC Secondary cidr in AWS.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_route_table.az_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.az_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.az_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.az_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.az_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.az_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_ssm_parameter.subnet_ida](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.subnet_idb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.subnet_idc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_subnet.subnet_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc_ipv4_cidr_block_association.rfc6598_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_ssm_parameter.parameter_transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_vpc_sec_cidr"></a> [create\_vpc\_sec\_cidr](#input\_create\_vpc\_sec\_cidr) | create secondary cidr integration with vpc if true | `bool` | `false` | no |
| <a name="input_parameter_sec_vpc_cidr"></a> [parameter\_sec\_vpc\_cidr](#input\_parameter\_sec\_vpc\_cidr) | secondary IP cidr assigned to the VPC | `string` | `"100.65.0.0/16"` | no |
| <a name="input_parameter_subnet_ida"></a> [parameter\_subnet\_ida](#input\_parameter\_subnet\_ida) | SSM parameter name to store subnet id a of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_subnet_idb"></a> [parameter\_subnet\_idb](#input\_parameter\_subnet\_idb) | SSM parameter name to store subnet id b of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_subnet_idc"></a> [parameter\_subnet\_idc](#input\_parameter\_subnet\_idc) | SSM parameter name to store subnet id c of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_transit_gateway"></a> [parameter\_transit\_gateway](#input\_parameter\_transit\_gateway) | Id of the transit gate-way | `string` | `null` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | SSM parameter name to store vpc id | `string` | `null` | no |
| <a name="input_subnet_a_cidr"></a> [subnet\_a\_cidr](#input\_subnet\_a\_cidr) | The IPv4 CIDR block assigned to the subnet\_a | `string` | `null` | no |
| <a name="input_subnet_a_name"></a> [subnet\_a\_name](#input\_subnet\_a\_name) | The name tag to assign to subnet A | `string` | `"subnet-azA"` | no |
| <a name="input_subnet_b_cidr"></a> [subnet\_b\_cidr](#input\_subnet\_b\_cidr) | The IPv4 CIDR block assigned to the subnet\_b | `string` | `null` | no |
| <a name="input_subnet_b_name"></a> [subnet\_b\_name](#input\_subnet\_b\_name) | The name tag to assign to subnet B | `string` | `"subnet-azB"` | no |
| <a name="input_subnet_c_cidr"></a> [subnet\_c\_cidr](#input\_subnet\_c\_cidr) | The IPv4 CIDR block assigned to the subnet\_c | `string` | `null` | no |
| <a name="input_subnet_c_name"></a> [subnet\_c\_name](#input\_subnet\_c\_name) | The name tag to assign to subnet C | `string` | `"subnet-azC"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_a_id"></a> [subnet\_a\_id](#output\_subnet\_a\_id) | The IDs of the Subnet A resources. |
| <a name="output_subnet_b_id"></a> [subnet\_b\_id](#output\_subnet\_b\_id) | The IDs of the Subnet B resources. |
| <a name="output_subnet_c_id"></a> [subnet\_c\_id](#output\_subnet\_c\_id) | The IDs of the Subnet C resources. |

<!-- END_TF_DOCS -->