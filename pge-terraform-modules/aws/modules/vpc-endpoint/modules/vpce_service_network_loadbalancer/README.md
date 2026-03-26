<!-- BEGIN_TF_DOCS -->
# AWS VPC-Endpoint-Gatewayloadbalancer module
Terraform module which creates SAF2.0 VPC-Endpoint service of type 'Gatewayloadbalancer' in AWS.

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
| [aws_vpc_endpoint_service.network_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acceptance_required"></a> [acceptance\_required](#input\_acceptance\_required) | Whether or not VPC endpoint connection requests to the service must be accepted by the service owner - true or false. | `bool` | n/a | yes |
| <a name="input_allowed_principals"></a> [allowed\_principals](#input\_allowed\_principals) | The ARNs of one or more principals allowed to discover the endpoint service. | `list(any)` | `null` | no |
| <a name="input_network_load_balancer_arns"></a> [network\_load\_balancer\_arns](#input\_network\_load\_balancer\_arns) | A list of network\_load\_balancer\_arns | `list(string)` | n/a | yes |
| <a name="input_private_dns_name"></a> [private\_dns\_name](#input\_private\_dns\_name) | The private DNS name for the service. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_endpoint_service_arn_networklb"></a> [vpc\_endpoint\_service\_arn\_networklb](#output\_vpc\_endpoint\_service\_arn\_networklb) | The ARN of the VPC endpoint Service for the Network Load Balancer. |
| <a name="output_vpc_endpoint_service_availability_zones_networklb"></a> [vpc\_endpoint\_service\_availability\_zones\_networklb](#output\_vpc\_endpoint\_service\_availability\_zones\_networklb) | The Availability Zones in which the service for the Network Load Balancer is available. |
| <a name="output_vpc_endpoint_service_base_endpoint_dns_names_networklb"></a> [vpc\_endpoint\_service\_base\_endpoint\_dns\_names\_networklb](#output\_vpc\_endpoint\_service\_base\_endpoint\_dns\_names\_networklb) | The DNS names for the service for the Network Load Balancer. |
| <a name="output_vpc_endpoint_service_id_networklb"></a> [vpc\_endpoint\_service\_id\_networklb](#output\_vpc\_endpoint\_service\_id\_networklb) | The ID of the VPC endpoint Service for the Network Load Balancer. |
| <a name="output_vpc_endpoint_service_manages_vpc_endpoints_networklb"></a> [vpc\_endpoint\_service\_manages\_vpc\_endpoints\_networklb](#output\_vpc\_endpoint\_service\_manages\_vpc\_endpoints\_networklb) | Whether or not the service manages its VPC endpoints - true or false. |
| <a name="output_vpc_endpoint_service_service_type_networklb"></a> [vpc\_endpoint\_service\_service\_type\_networklb](#output\_vpc\_endpoint\_service\_service\_type\_networklb) | The service\_type of the VPC endpoint Service for the Network Load Balancer. |
| <a name="output_vpc_endpoint_service_servicename_networklb"></a> [vpc\_endpoint\_service\_servicename\_networklb](#output\_vpc\_endpoint\_service\_servicename\_networklb) | The service\_name of the VPC endpoint Service for the Network Load Balancer. |
| <a name="output_vpc_endpoint_service_state_networklb"></a> [vpc\_endpoint\_service\_state\_networklb](#output\_vpc\_endpoint\_service\_state\_networklb) | Verification state of the VPC endpoint service for the Network Load Balancer. Consumers of the endpoint service can use the private name only when the state is verified. |
| <a name="output_vpc_endpoint_service_tags_all_networklb"></a> [vpc\_endpoint\_service\_tags\_all\_networklb](#output\_vpc\_endpoint\_service\_tags\_all\_networklb) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->