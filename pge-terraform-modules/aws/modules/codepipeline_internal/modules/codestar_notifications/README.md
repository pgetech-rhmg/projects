# CodeStar Notifications Module

Creates SNS topics and Lambda function for CodePipeline build notifications.

## Changelog

### v0.1.8
- **Fixed:** Lambda function was being recreated on every `terraform plan/apply` due to archive zip timestamp changes
- **Solution:** Use `filesha256()` on the actual source file to detect real code changes and embed hash in Lambda description

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

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
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_security-group-snslambda"></a> [security-group-snslambda](#module\_security-group-snslambda) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codestarnotifications_notification_rule.build_notify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarnotifications_notification_rule) | resource |
| [aws_iam_policy.policy_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.role_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.with_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.sns-topic-trigger-email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.sns-topic-trigger-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_trigger_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.sns_trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.sns_topic_subscription_trigger_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.sns_topic_subscription_trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_egress_rules_SNS_codestar"></a> [cidr\_egress\_rules\_SNS\_codestar](#input\_cidr\_egress\_rules\_SNS\_codestar) | egress rule for codestar | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_codepipeline_arn"></a> [codepipeline\_arn](#input\_codepipeline\_arn) | codepipeline arn | `string` | `""` | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_codestar_environment"></a> [codestar\_environment](#input\_codestar\_environment) | lambda environment | `string` | n/a | yes |
| <a name="input_codestar_lambda_encryption_key_id"></a> [codestar\_lambda\_encryption\_key\_id](#input\_codestar\_lambda\_encryption\_key\_id) | The KMS key ARN for codestar notifications | `string` | `null` | no |
| <a name="input_codestar_sns_kms_key_arn"></a> [codestar\_sns\_kms\_key\_arn](#input\_codestar\_sns\_kms\_key\_arn) | Enter the KMS key arn for encryption - codestar notifications | `string` | `null` | no |
| <a name="input_endpoint_email"></a> [endpoint\_email](#input\_endpoint\_email) | Endpoint to send data to. The contents vary with the protocol | `list(any)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Valid JSON document representing a resource policy | `string` | `"{}"` | no |
| <a name="input_run_time"></a> [run\_time](#input\_run\_time) | run\_time version | `string` | `"python3.12"` | no |
| <a name="input_sg_description_codestar"></a> [sg\_description\_codestar](#input\_sg\_description\_codestar) | snslambda security group | `string` | `"security group for snslambda"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs within which to run builds. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | enter the vpc id within which to run builds. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_sns_arn"></a> [sns\_arn](#output\_sns\_arn) | Arn of the sns |

<!-- END_TF_DOCS -->