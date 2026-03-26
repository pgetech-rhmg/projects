<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_redshift_authentication_profile.authentication_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_authentication_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_profile_content"></a> [authentication\_profile\_content](#input\_authentication\_profile\_content) | Authentication profile policy file name | `string` | n/a | yes |
| <a name="input_authentication_profile_name"></a> [authentication\_profile\_name](#input\_authentication\_profile\_name) | The name of the authentication profile. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authentication_profile_id"></a> [authentication\_profile\_id](#output\_authentication\_profile\_id) | The name of the authentication profile. |
| <a name="output_aws_redshift_authentication_profile_all"></a> [aws\_redshift\_authentication\_profile\_all](#output\_aws\_redshift\_authentication\_profile\_all) | A map of all aws redshift authentication profile attribute references |

<!-- END_TF_DOCS -->