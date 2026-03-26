<!-- BEGIN_TF_DOCS -->
# AWS Glue workflow module.
Terraform module which creates SAF2.0 Glue workflow in AWS.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_workflow.glue_workflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_workflow) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_workflow_default_run_properties"></a> [glue\_workflow\_default\_run\_properties](#input\_glue\_workflow\_default\_run\_properties) | A map of default run properties for this workflow. These properties are passed to all jobs associated to the workflow. | `map(string)` | `{}` | no |
| <a name="input_glue_workflow_description"></a> [glue\_workflow\_description](#input\_glue\_workflow\_description) | Description of the workflow. | `string` | `null` | no |
| <a name="input_glue_workflow_max_concurrent_runs"></a> [glue\_workflow\_max\_concurrent\_runs](#input\_glue\_workflow\_max\_concurrent\_runs) | Prevents exceeding the maximum number of concurrent runs of any of the component jobs. If you leave this parameter blank, there is no limit to the number of concurrent workflow runs. | `number` | `null` | no |
| <a name="input_glue_workflow_name"></a> [glue\_workflow\_name](#input\_glue\_workflow\_name) | The name you assign to this workflow. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_workflow"></a> [aws\_glue\_workflow](#output\_aws\_glue\_workflow) | A map of aws\_glue\_workflow object. |
| <a name="output_glue_workflow_arn"></a> [glue\_workflow\_arn](#output\_glue\_workflow\_arn) | Amazon Resource Name (ARN) of Glue Workflow |
| <a name="output_glue_workflow_id"></a> [glue\_workflow\_id](#output\_glue\_workflow\_id) | Workflow name |
| <a name="output_glue_workflow_tags_all"></a> [glue\_workflow\_tags\_all](#output\_glue\_workflow\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->