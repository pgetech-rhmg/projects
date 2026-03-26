<!-- BEGIN_TF_DOCS -->
# AWS WAF Ip Set Cloudfront module
Terraform module which creates SAF2.0 WAF Ip Set Cloudfront in AWS

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.wafv2_ip_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_wafv2_ip_set_addresses"></a> [wafv2\_ip\_set\_addresses](#input\_wafv2\_ip\_set\_addresses) | Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6. | `list(string)` | n/a | yes |
| <a name="input_wafv2_ip_set_description"></a> [wafv2\_ip\_set\_description](#input\_wafv2\_ip\_set\_description) | A friendly description of the IP set. | `string` | `null` | no |
| <a name="input_wafv2_ip_set_ip_address_version"></a> [wafv2\_ip\_set\_ip\_address\_version](#input\_wafv2\_ip\_set\_ip\_address\_version) | Specify IPV4 or IPV6. Valid values are IPV4 or IPV6. | `string` | n/a | yes |
| <a name="input_wafv2_ip_set_name"></a> [wafv2\_ip\_set\_name](#input\_wafv2\_ip\_set\_name) | A friendly name of the IP set. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_wafv2_ip_set_all"></a> [aws\_wafv2\_ip\_set\_all](#output\_aws\_wafv2\_ip\_set\_all) | Map of all aws\_wafv2\_ip\_set |
| <a name="output_ip_set_arn"></a> [ip\_set\_arn](#output\_ip\_set\_arn) | The Amazon Resource Name (ARN) that identifies the cluster. |
| <a name="output_ip_set_id"></a> [ip\_set\_id](#output\_ip\_set\_id) | A unique identifier for the set. |
| <a name="output_ip_set_tags_all"></a> [ip\_set\_tags\_all](#output\_ip\_set\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->