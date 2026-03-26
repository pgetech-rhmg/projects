<!-- BEGIN_TF_DOCS -->
# AWS Opensearch  module.
Terraform module which creates SAF2.0 Opensearch.0 in AWS.

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
| [aws_opensearch_inbound_connection_accepter.connection_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_inbound_connection_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection_id"></a> [connection\_id](#input\_connection\_id) | ID of the connection to accept. | `any` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_opensearch_inbound_connection_accepter_all"></a> [aws\_opensearch\_inbound\_connection\_accepter\_all](#output\_aws\_opensearch\_inbound\_connection\_accepter\_all) | Map of all Inbound Connection accepter attributes |
| <a name="output_aws_opensearch_inbound_connection_accepter_id"></a> [aws\_opensearch\_inbound\_connection\_accepter\_id](#output\_aws\_opensearch\_inbound\_connection\_accepter\_id) | Connection accepter ID |
| <a name="output_aws_opensearch_inbound_connection_accepter_status"></a> [aws\_opensearch\_inbound\_connection\_accepter\_status](#output\_aws\_opensearch\_inbound\_connection\_accepter\_status) | Connection accepter status |

<!-- END_TF_DOCS -->