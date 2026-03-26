<!-- BEGIN_TF_DOCS -->
# AWS Opensearch domain module.
Terraform module which creates Opensearch domain in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.36.0 |

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
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_opensearch_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_options"></a> [advanced\_options](#input\_advanced\_options) | Key-value string pairs to specify advanced configuration options | `map(string)` | n/a | yes |
| <a name="input_advanced_security_options"></a> [advanced\_security\_options](#input\_advanced\_security\_options) | Advanced security options | `list(any)` | n/a | yes |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Configuration block for Cluster | `list(any)` | `[]` | no |
| <a name="input_domain_endpoint_options"></a> [domain\_endpoint\_options](#input\_domain\_endpoint\_options) | Domain Endpoint options block | `list(any)` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | OpenSearch Domain name | `string` | n/a | yes |
| <a name="input_ebs_options"></a> [ebs\_options](#input\_ebs\_options) | Configuration block for EBS options | `list(any)` | `[]` | no |
| <a name="input_encrypt_at_rest_options"></a> [encrypt\_at\_rest\_options](#input\_encrypt\_at\_rest\_options) | Configuration block for encryption at rest options | `list(any)` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Opensearch engine version | `string` | `"OpenSearch_2.11"` | no |
| <a name="input_log_publishing_options"></a> [log\_publishing\_options](#input\_log\_publishing\_options) | Configuration block for log publishing options | `list(any)` | n/a | yes |
| <a name="input_node_to_node_encryption_options"></a> [node\_to\_node\_encryption\_options](#input\_node\_to\_node\_encryption\_options) | Configuration block for encryption options | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(any)` | `{}` | no |
| <a name="input_vpc_options"></a> [vpc\_options](#input\_vpc\_options) | Configuration block for VPC options | `list(any)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_all"></a> [domain\_all](#output\_domain\_all) | Map of all Domain attributes |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the Domain |
| <a name="output_domain_dashboard_endpoint"></a> [domain\_dashboard\_endpoint](#output\_domain\_dashboard\_endpoint) | Domain Dashboard endpoint |
| <a name="output_domain_endpoint"></a> [domain\_endpoint](#output\_domain\_endpoint) | Domain endpoint |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Unique identifier (ID) of the Domain. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the Domain |

<!-- END_TF_DOCS -->