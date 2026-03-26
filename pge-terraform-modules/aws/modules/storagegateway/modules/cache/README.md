<!-- BEGIN_TF_DOCS -->
# AWS Storage gateway cache
Terraform module which creates SAF2.0 storage gateway cache in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_storagegateway_cache.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_cache) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disk_id"></a> [disk\_id](#input\_disk\_id) | Local disk identifier. | `string` | n/a | yes |
| <a name="input_gateway_arn"></a> [gateway\_arn](#input\_gateway\_arn) | The Amazon Resource Name (ARN) of the gateway. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_id"></a> [cache\_id](#output\_cache\_id) | Combined gateway Amazon Resource Name (ARN) and local disk identifier. |


<!-- END_TF_DOCS -->