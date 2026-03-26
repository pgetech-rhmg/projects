<!-- BEGIN_TF_DOCS -->
# AWS Amplify Domain Association module.
Terraform module which creates SAF2.0 Amplify Domain Association in AWS.

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
| [aws_amplify_domain_association.amplify_domain_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_domain_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Unique ID for an Amplify app. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the domain association. | `string` | n/a | yes |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Setting for the subdomain. | `list(map(string))` | n/a | yes |
| <a name="input_wait_for_verification"></a> [wait\_for\_verification](#input\_wait\_for\_verification) | If enabled, the resource will wait for the domain association status to change to PENDING\_DEPLOYMENT or AVAILABLE. Setting this to false will skip the process. Default: true. | `bool` | `true` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_domain_association_all"></a> [amplify\_domain\_association\_all](#output\_amplify\_domain\_association\_all) | A map of aws amplify domain association |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN for the domain\_association. |
| <a name="output_certificate_verification_dns_record"></a> [certificate\_verification\_dns\_record](#output\_certificate\_verification\_dns\_record) | The DNS record for certificate verification. |
| <a name="output_sub_domain"></a> [sub\_domain](#output\_sub\_domain) | DNS record and Verified status for the subdomain. |

<!-- END_TF_DOCS -->