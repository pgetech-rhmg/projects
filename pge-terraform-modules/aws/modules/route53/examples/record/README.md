<!-- BEGIN_TF_DOCS -->
# AWS Route53 module Record example

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
| <a name="module_records"></a> [records](#module\_records) | ../../ | n/a |
| <a name="module_records_with_policy"></a> [records\_with\_policy](#module\_records\_with\_policy) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The ID of the hosted zone to contain this record. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN built using the zone domain and name. |
| <a name="output_fqdn_records_with_policy"></a> [fqdn\_records\_with\_policy](#output\_fqdn\_records\_with\_policy) | FQDN built using the zone domain and name. |
| <a name="output_name"></a> [name](#output\_name) | The name of the record. |
| <a name="output_name_of_records_with_policy"></a> [name\_of\_records\_with\_policy](#output\_name\_of\_records\_with\_policy) | The name of the record. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Zone id of the route 53 hosted zone. |

<!-- END_TF_DOCS -->