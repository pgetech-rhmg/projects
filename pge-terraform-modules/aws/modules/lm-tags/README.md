<!-- BEGIN_TF_DOCS -->
# Locate & Mark Tags Terraform Module
Terraform module to manage required tags for Locate & MArk

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.89.0 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.tag_appid](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_compliance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_cris](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_dataclassification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_notify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_order](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.tag_owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appid"></a> [appid](#input\_appid) | Override for tag value appid | `string` | `"/lm/common_tags/appid"` | no |
| <a name="input_compliance"></a> [compliance](#input\_compliance) | Override for tag value compliance | `string` | `"/lm/common_tags/compliance"` | no |
| <a name="input_cris"></a> [cris](#input\_cris) | Override for tag value cris | `string` | `"/lm/common_tags/cris"` | no |
| <a name="input_dataclassification"></a> [dataclassification](#input\_dataclassification) | Override for tag value dataclassification | `string` | `"/lm/common_tags/dataclassification"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Override for tag value environment | `string` | `"/lm/common_tags/environment"` | no |
| <a name="input_notify"></a> [notify](#input\_notify) | Override for tag value notify | `string` | `"/lm/common_tags/notify"` | no |
| <a name="input_order"></a> [order](#input\_order) | Override for tag value owner | `string` | `"/lm/common_tags/order"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Override for tag value owner | `string` | `"/lm/common_tags/owner"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tags"></a> [tags](#output\_tags) | Filename    : modules/lm-tags/outputs.tf Date        : 28 Feb 2025 Author      : Sean Fairchild (s3ff@pge.com) Description : This terraform module applies mandatory tags to Locate & Mark the resources. |

<!-- END_TF_DOCS -->
