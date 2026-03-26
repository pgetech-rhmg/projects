<!-- BEGIN_TF_DOCS -->
# AWS EBS module
Terraform module which creates SAF2.0 EBS from snapshot in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| [aws_ebs_volume.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_volume_attachment.volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The names of the availability zone | `string` | n/a | yes |
| <a name="input_device_name"></a> [device\_name](#input\_device\_name) | The device name to expose to the instance | `string` | n/a | yes |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | Id of the ec2 instance. | `list(string)` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key | `string` | `null` | no |
| <a name="input_multi_attach_enabled"></a> [multi\_attach\_enabled](#input\_multi\_attach\_enabled) | Specifies whether to enable Amazon EBS Multi-Attach. Multi-Attach is supported exclusively on io1 volumes. | `bool` | `false` | no |
| <a name="input_snapshot_id"></a> [snapshot\_id](#input\_snapshot\_id) | A snapshot to base the EBS volume. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | The throughput that the volume supports, in MiB/s. Only valid for type of gp3. | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1. | `string` | `"gp2"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_volume_arn"></a> [volume\_arn](#output\_volume\_arn) | The ARN of EBS |
| <a name="output_volume_id"></a> [volume\_id](#output\_volume\_id) | The ID of EBS |
| <a name="output_volume_tags_all"></a> [volume\_tags\_all](#output\_volume\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->