<!-- BEGIN_TF_DOCS -->
# AWS VPC-Endpoint-Interface module
Terraform module which creates SAF2.0 VPC-Endpoint of type 'Interface' in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.92.0 |

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
| [aws_vpc_endpoint.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc_endpoint_service.vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account) | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid policy JSON document. For more information about building AWS IAM policy documents with Terraform. | `string` | `"{}"` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC | `bool` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface | `list(any)` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for the endpoint | `list(any)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_endpoint_arn"></a> [vpc\_endpoint\_arn](#output\_vpc\_endpoint\_arn) | The Amazon Resource Name (ARN) of the VPC endpoint |
| <a name="output_vpc_endpoint_dns_entry"></a> [vpc\_endpoint\_dns\_entry](#output\_vpc\_endpoint\_dns\_entry) | The DNS entries for the VPC Endpoint |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | The ID of the VPC endpoint |
| <a name="output_vpc_endpoint_network_interface_ids"></a> [vpc\_endpoint\_network\_interface\_ids](#output\_vpc\_endpoint\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint |
| <a name="output_vpc_endpoint_owner_id"></a> [vpc\_endpoint\_owner\_id](#output\_vpc\_endpoint\_owner\_id) | The ID of the AWS account that owns the VPC endpoint |
| <a name="output_vpc_endpoint_requester_managed"></a> [vpc\_endpoint\_requester\_managed](#output\_vpc\_endpoint\_requester\_managed) | Whether or not the VPC Endpoint is being managed by its service |
| <a name="output_vpc_endpoint_state"></a> [vpc\_endpoint\_state](#output\_vpc\_endpoint\_state) | The state of the VPC endpoint |
| <a name="output_vpc_endpoint_tags_all"></a> [vpc\_endpoint\_tags\_all](#output\_vpc\_endpoint\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |


<!-- END_TF_DOCS -->