<!-- BEGIN_TF_DOCS -->
# PG&E Mrad ECS Module
 MRAD specific composite CW rules module to provision SAF compliant resources

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

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
| <a name="module_aws_cloudwatch_event_iam_role"></a> [aws\_cloudwatch\_event\_iam\_role](#module\_aws\_cloudwatch\_event\_iam\_role) | app.terraform.io/pgetech/iam/aws//modules/iam_role | 0.0.8 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.target_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy_document.invoke_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | Any additional security groups to be added to ECS | `list(string)` | `[]` | no |
| <a name="input_arn"></a> [arn](#input\_arn) | The ARN of the resource you're triggering through the CloudWatch Rule | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Aws account name, Dev, QA, Prod | `string` | n/a | yes |
| <a name="input_branch"></a> [branch](#input\_branch) | Indicates the branch being deployed, used to namespace resource names to prevent conflicts | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description for the CloudWatch Rule | `string` | n/a | yes |
| <a name="input_ecs"></a> [ecs](#input\_ecs) | Is this targeting an ECS Task or not | `bool` | `false` | no |
| <a name="input_ecs_security_group_id"></a> [ecs\_security\_group\_id](#input\_ecs\_security\_group\_id) | security group ID from the ECS module | `string` | `"none"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | If the CloudWatch Rule is enabled or not | `bool` | `true` | no |
| <a name="input_input"></a> [input](#input\_input) | The input you're sending through the CloudWatch Rule | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the service that this Rule is associated with | `string` | n/a | yes |
| <a name="input_partner"></a> [partner](#input\_partner) | partner team name | `string` | `"MRAD"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule expression for the CloudWatch Rule | `string` | `null` | no |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | subnet1 name | `string` | `""` | no |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | subnet2 name | `string` | `""` | no |
| <a name="input_subnet3"></a> [subnet3](#input\_subnet3) | subnet3 name | `string` | `""` | no |
| <a name="input_subnet_qualifier"></a> [subnet\_qualifier](#input\_subnet\_qualifier) | The subnet qualifier | `map(any)` | <pre>{<br/>  "Dev": "Dev-2",<br/>  "Prod": "Prod",<br/>  "QA": "QA",<br/>  "Test": "Test-2"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to CW rules | `map(string)` | `{}` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | task definition arn that should targeted | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |

<!-- END_TF_DOCS -->