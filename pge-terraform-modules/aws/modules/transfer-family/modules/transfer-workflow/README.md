<!-- BEGIN_TF_DOCS -->
# AWS Transfer family workfloiw module.
Terraform module which creates SAF2.0 aws\_transfer\_workflow in AWS.

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
| [aws_transfer_workflow.transfer_workflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_workflow) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A textual description for the workflow. | `string` | `null` | no |
| <a name="input_on_exception_steps"></a> [on\_exception\_steps](#input\_on\_exception\_steps) | Specifies the steps (actions) to take if errors are encountered during execution of the workflow. | `any` | `[]` | no |
| <a name="input_steps"></a> [steps](#input\_steps) | Specifies the details for the steps that are in the specified workflow. | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transfer_workflow_all"></a> [transfer\_workflow\_all](#output\_transfer\_workflow\_all) | Map of transfer\_workflow object |
| <a name="output_transfer_workflow_arn"></a> [transfer\_workflow\_arn](#output\_transfer\_workflow\_arn) | The Workflow ARN. |
| <a name="output_transfer_workflow_id"></a> [transfer\_workflow\_id](#output\_transfer\_workflow\_id) | The Workflow id. |
| <a name="output_transfer_workflow_tags_all"></a> [transfer\_workflow\_tags\_all](#output\_transfer\_workflow\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->