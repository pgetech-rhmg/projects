<!-- BEGIN_TF_DOCS -->
# AWS Redshift
Terraform module which creates SAF2.0 Redshift endpoint\_access in AWS

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
| [aws_redshift_endpoint_access.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_endpoint_access) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The cluster identifier of the cluster to access. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The Redshift-managed VPC endpoint name. | `string` | n/a | yes |
| <a name="input_resource_owner"></a> [resource\_owner](#input\_resource\_owner) | The Amazon Web Services account ID of the owner of the cluster. This is only required if the cluster is in another Amazon Web Services account. | `string` | `""` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | The subnet group from which Amazon Redshift chooses the subnet to deploy the endpoint. | `string` | n/a | yes |
| <a name="input_vpc_sg_ids"></a> [vpc\_sg\_ids](#input\_vpc\_sg\_ids) | The security group that defines the ports, protocols, and sources for inbound traffic that you are authorizing into your endpoint. | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_endpoint_access_all"></a> [aws\_redshift\_endpoint\_access\_all](#output\_aws\_redshift\_endpoint\_access\_all) | A map of aws redshift endpoint access attributes references |
| <a name="output_endpoint_address"></a> [endpoint\_address](#output\_endpoint\_address) | The DNS address of the endpoint. |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | The Redshift-managed VPC endpoint name. |
| <a name="output_endpoint_port"></a> [endpoint\_port](#output\_endpoint\_port) | The port number on which the cluster accepts incoming connections. |
| <a name="output_vpc_endpoint"></a> [vpc\_endpoint](#output\_vpc\_endpoint) | The connection endpoint for connecting to an Amazon Redshift cluster through the proxy. |

<!-- END_TF_DOCS -->