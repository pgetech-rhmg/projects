# AWS ACM Terraform module

 Terraform base module for deploying and managing ACM modules (acm_import_certificate, acm_private_ca, acm_public_certificate) on Amazon Web Services (AWS). Default ACM code is for acm_public_certificate.

 ACM Modules can be found at `acm/modules/*`

 ACM Modules examples can be found at `acm/examples/*`
<!-- BEGIN_TF_DOCS -->
# AWS ACM module creating public certificate
Terraform module which creates SAF2.0 ACM in AWS.
This module will handle the record creation in Route53 if acm\_r53update\_validate is set to true.By default, it will launch into public zone of r53 account.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.91.0|
| <a name="provider_aws.r53"></a> [aws.r53](#provider\_aws.r53) | >= 5.91.0|

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
| [aws_acm_certificate.acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.acm_r53record_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.public_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_domain_name"></a> [acm\_domain\_name](#input\_acm\_domain\_name) | A domain name for which the certificate should be issued. | `string` | n/a | yes |
| <a name="input_acm_r53update_validate"></a> [acm\_r53update\_validate](#input\_acm\_r53update\_validate) | variable to set route53 addition with the certificate creation. | `bool` | `true` | no |
| <a name="input_acm_subject_alternative_names"></a> [acm\_subject\_alternative\_names](#input\_acm\_subject\_alternative\_names) | Set of domains that should be SANs in the issued certificate. | `list(string)` | `null` | no |
| <a name="input_acm_validation_create_timeouts"></a> [acm\_validation\_create\_timeouts](#input\_acm\_validation\_create\_timeouts) | How long to wait for a certificate to be issued. | `string` | `"2880m"` | no |
| <a name="input_acm_validation_record_fqdns"></a> [acm\_validation\_record\_fqdns](#input\_acm\_validation\_record\_fqdns) | List of FQDNs that implement the validation. | `list(string)` | `null` | no |
| <a name="input_allow_overwrite"></a> [allow\_overwrite](#input\_allow\_overwrite) | Allow creation of this record in Terraform to overwrite an existing record. | `bool` | `false` | no |
| <a name="input_certificate_transparency_logging_preference"></a> [certificate\_transparency\_logging\_preference](#input\_certificate\_transparency\_logging\_preference) | Specifies whether certificate details should be added to a certificate transparency log. | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The TTL of the record. | `number` | `60` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate"></a> [acm\_certificate](#output\_acm\_certificate) | Map of the acm certificate |
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | The ARN of the certificate |
| <a name="output_acm_certificate_domain_name"></a> [acm\_certificate\_domain\_name](#output\_acm\_certificate\_domain\_name) | The domain name for which the certificate is issued |
| <a name="output_acm_certificate_domain_validation_options"></a> [acm\_certificate\_domain\_validation\_options](#output\_acm\_certificate\_domain\_validation\_options) | Set of domain validation objects which can be used to complete certificate validation |
| <a name="output_acm_certificate_id"></a> [acm\_certificate\_id](#output\_acm\_certificate\_id) | The ID of the certificate |
| <a name="output_acm_certificate_status"></a> [acm\_certificate\_status](#output\_acm\_certificate\_status) | Status of the certificate |
| <a name="output_acm_certificate_tags_all"></a> [acm\_certificate\_tags\_all](#output\_acm\_certificate\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_acm_certificate_validation"></a> [acm\_certificate\_validation](#output\_acm\_certificate\_validation) | Map of the acm cert validation object |
| <a name="output_certificate_validation_id"></a> [certificate\_validation\_id](#output\_certificate\_validation\_id) | The time at which the certificate was issued |
| <a name="output_route53_record"></a> [route53\_record](#output\_route53\_record) | Map of the route53 record |

<!-- END_TF_DOCS -->