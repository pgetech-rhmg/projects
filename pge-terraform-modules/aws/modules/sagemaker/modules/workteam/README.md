<!-- BEGIN_TF_DOCS -->
# AWS Sagemaker module
# Terraform module which creates Sagemaker Workteam

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sagemaker_workteam.workteam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_workteam) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A description of the work team. | `string` | `null` | no |
| <a name="input_member_definition"></a> [member\_definition](#input\_member\_definition) | cognito\_member\_definition:<br/> The Amazon Cognito user group that is part of the work team.<br/>oidc\_member\_definition:<br/> A list user groups that exist in your OIDC Identity Provider (IdP).One to ten groups can be used to create a single private work team. | <pre>object({<br/>    cognito_member_definition = any<br/>    oidc_member_definition    = any<br/>  })</pre> | <pre>{<br/>  "cognito_member_definition": {},<br/>  "oidc_member_definition": {}<br/>}</pre> | no |
| <a name="input_notification_configuration"></a> [notification\_configuration](#input\_notification\_configuration) | Configures notification of workers regarding available or expiring work items. | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_workforce_name"></a> [workforce\_name](#input\_workforce\_name) | The name of the workforce. | `string` | n/a | yes |
| <a name="input_workteam_name"></a> [workteam\_name](#input\_workteam\_name) | The name of the Workteam (must be unique). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_workteam_all"></a> [sagemaker\_workteam\_all](#output\_sagemaker\_workteam\_all) | A map of aws sagemaker workteam |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_workteam_arn"></a> [workteam\_arn](#output\_workteam\_arn) | The Amazon Resource Name (ARN) assigned by AWS to this Workteam. |
| <a name="output_workteam_id"></a> [workteam\_id](#output\_workteam\_id) | The name of the Workteam. |
| <a name="output_workteam_subdomain"></a> [workteam\_subdomain](#output\_workteam\_subdomain) | The subdomain for your OIDC Identity Provider. |

<!-- END_TF_DOCS -->