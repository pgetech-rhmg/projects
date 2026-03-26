<!-- BEGIN_TF_DOCS -->


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
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoint_service_gateway_load_balancer"></a> [vpc\_endpoint\_service\_gateway\_load\_balancer](#module\_vpc\_endpoint\_service\_gateway\_load\_balancer) | ../../modules/vpce_service_gateway_loadbalancer | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lb.glb1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.glb2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_acceptance_required"></a> [acceptance\_required](#input\_acceptance\_required) | Whether or not VPC endpoint connection requests to the service must be accepted by the service owner - true or false. | `bool` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of load balancer to create. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The resource name and Name tag of the load balancer. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_subnet_id2_name"></a> [subnet\_id2\_name](#input\_subnet\_id2\_name) | The name given in the parameter store for the subnet id 3 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_endpoint_service_arn_gatewaylb"></a> [vpc\_endpoint\_service\_arn\_gatewaylb](#output\_vpc\_endpoint\_service\_arn\_gatewaylb) | The ARN of the VPC endpoint Service for the Gateway Load Balancer. |
| <a name="output_vpc_endpoint_service_availability_zones_gatewaylb"></a> [vpc\_endpoint\_service\_availability\_zones\_gatewaylb](#output\_vpc\_endpoint\_service\_availability\_zones\_gatewaylb) | The Availability Zones in which the service is available. |
| <a name="output_vpc_endpoint_service_base_endpoint_dns_names_gatewaylb"></a> [vpc\_endpoint\_service\_base\_endpoint\_dns\_names\_gatewaylb](#output\_vpc\_endpoint\_service\_base\_endpoint\_dns\_names\_gatewaylb) | The DNS names for the service. |
| <a name="output_vpc_endpoint_service_id_gatewaylb"></a> [vpc\_endpoint\_service\_id\_gatewaylb](#output\_vpc\_endpoint\_service\_id\_gatewaylb) | The ID of the VPC endpoint Service for the Gateway Load Balancer. |
| <a name="output_vpc_endpoint_service_manages_vpc_endpoints_gatewaylb"></a> [vpc\_endpoint\_service\_manages\_vpc\_endpoints\_gatewaylb](#output\_vpc\_endpoint\_service\_manages\_vpc\_endpoints\_gatewaylb) | Whether or not the service manages its VPC endpoints - true or false. |
| <a name="output_vpc_endpoint_service_service_name_gatewaylb"></a> [vpc\_endpoint\_service\_service\_name\_gatewaylb](#output\_vpc\_endpoint\_service\_service\_name\_gatewaylb) | The service\_name of the VPC endpoint Service for the Gateway Load Balancer |
| <a name="output_vpc_endpoint_service_service_type_gatewaylb"></a> [vpc\_endpoint\_service\_service\_type\_gatewaylb](#output\_vpc\_endpoint\_service\_service\_type\_gatewaylb) | The service\_type of the VPC endpoint Service for the Gateway Load Balancer |
| <a name="output_vpc_endpoint_service_state_gatewaylb"></a> [vpc\_endpoint\_service\_state\_gatewaylb](#output\_vpc\_endpoint\_service\_state\_gatewaylb) | The state of the VPC endpoint service. |
| <a name="output_vpc_endpoint_service_tags_all_gatewaylb"></a> [vpc\_endpoint\_service\_tags\_all\_gatewaylb](#output\_vpc\_endpoint\_service\_tags\_all\_gatewaylb) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->