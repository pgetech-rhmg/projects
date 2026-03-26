<!-- BEGIN_TF_DOCS -->
# AWS Cognito identity pool.
Terraform module which creates SAF2.0 Cognito identity pool in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.90.1 |

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
| [aws_cognito_identity_pool.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_iam_role.authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_classic_flow"></a> [allow\_classic\_flow](#input\_allow\_classic\_flow) | Whether the identity pool allows the classic flow or not | `bool` | `false` | no |
| <a name="input_allow_unauthenticated_identities"></a> [allow\_unauthenticated\_identities](#input\_allow\_unauthenticated\_identities) | Whether the identity pool supports unauthenticated logins or not | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the role | `string` | `"IAM Role created by pge_team = ccoe-tf-developers"` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether to force detaching any policies the role has before destroying it | `bool` | `false` | no |
| <a name="input_identity_pool_name"></a> [identity\_pool\_name](#input\_identity\_pool\_name) | The name of the identity pool | `string` | n/a | yes |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | A list of strings.  Each string should contain a json string to use for this inline policy or pass as a file name in json | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `number` | `3600` | no |
| <a name="input_name"></a> [name](#input\_name) | The name prefix for these IAM resources | `string` | n/a | yes |
| <a name="input_openid_connect_provider_arns"></a> [openid\_connect\_provider\_arns](#input\_openid\_connect\_provider\_arns) | A list of OpenID Connect provider ARNs | `list(string)` | `[]` | no |
| <a name="input_path"></a> [path](#input\_path) | The path to the role in IAM | `string` | `"/"` | no |
| <a name="input_permission_boundary"></a> [permission\_boundary](#input\_permission\_boundary) | IAM policy ARN limiting the maximum access this role can have | `string` | `""` | no |
| <a name="input_saml_provider_arns"></a> [saml\_provider\_arns](#input\_saml\_provider\_arns) | A list of SAML provider ARNs | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authenticated_role_arn"></a> [authenticated\_role\_arn](#output\_authenticated\_role\_arn) | value of the authenticated role arn |
| <a name="output_cognito_identity_pool"></a> [cognito\_identity\_pool](#output\_cognito\_identity\_pool) | map of aws congito identity pool |
| <a name="output_cognito_identity_pool_allow_unauthenticated_identities"></a> [cognito\_identity\_pool\_allow\_unauthenticated\_identities](#output\_cognito\_identity\_pool\_allow\_unauthenticated\_identities) | value of the cognito identity pool allow unauthenticated identities |
| <a name="output_cognito_identity_pool_arn"></a> [cognito\_identity\_pool\_arn](#output\_cognito\_identity\_pool\_arn) | value of the cognito identity pool arn |
| <a name="output_cognito_identity_pool_id"></a> [cognito\_identity\_pool\_id](#output\_cognito\_identity\_pool\_id) | value of the cognito identity pool id |
| <a name="output_cognito_identity_pool_openid_connect_provider_arns"></a> [cognito\_identity\_pool\_openid\_connect\_provider\_arns](#output\_cognito\_identity\_pool\_openid\_connect\_provider\_arns) | value of the cognito identity pool openid connect provider arns |
| <a name="output_cognito_identity_pool_saml_provider_arns"></a> [cognito\_identity\_pool\_saml\_provider\_arns](#output\_cognito\_identity\_pool\_saml\_provider\_arns) | value of the cognito identity pool saml provider arns |
| <a name="output_identity_pool_roles_attachment"></a> [identity\_pool\_roles\_attachment](#output\_identity\_pool\_roles\_attachment) | value of the identity pool roles attachment |

<!-- END_TF_DOCS -->