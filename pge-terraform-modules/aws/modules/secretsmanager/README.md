# AWS Secrets Manager Terraform module

Terraform module which creates AWS Secrets Manager.

## Usage
##### Secrets manager with a custom policy
```hcl

module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days                      #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  custom_policy              = file("${path.module}/${var.policy_file_name}")
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```

##### Secrets manager with key value entries
```hcl  

module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days                  #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = jsonencode(var.secret_string)
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```

##### Secrets manager with plain text
```hcl

module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days            #this is set to 0 days for testing. for safety purpose the default is set to 30 days
  secret_string              = var.secret_string
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```
##### Secrets manager with binary
```hcl
module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days                     #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_binary              = var.secret_binary
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```
##### Secrets manager with cross region replica
```hcl

module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  replica_kms_key_id         = module.kms_key.key_arn      #this should be replaced with replica kms key.
  replica_region             = var.replica_region
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```
##### Secrets manager with rotation
```hcl

module "secretsmanager" {
  source                     = "../../../../modules/secretsmanager"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days    = var.recovery_window_in_days                #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = var.secret_string
  secret_version_enabled     = var.secret_version_enabled
  rotation_enabled           = var.rotation_enabled
  rotation_lambda_arn        = module.lambda_function.lambda_function_arn
  rotation_after_days        = var.rotation_after_days
  tags                       = merge(module.tags.tags, local.optional_tags)
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.27 |


## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |


## Inputs


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| secretsmanager_name | Name of the new secret. This value conflicts with secretsmanager_name_prefix. | `string` | `null` | no |
| secretsmanager_name_prefix | Creates a unique name beginning with the specified prefix. This value conflicts with secretsmanager_name. | `string` | `null` | no |
| secretsmanager_description | Description of the secret | `string` | `null` | no |
| kms_key_id | ARN or Id of the AWS KMS customer master key | `string` |  | yes |
| custom_policy | Valid JSON document representing a resource policy | `string` | `null` | yes |
| recovery_window_in_days | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | 30 | yes |
| replica_kms_key_id | ARN or ID of the AWS KMS for replica | `string` | `null` | no |
| replica_region | Region for replicating the secret | `string` | `null` | no |
| tags | Key-value map of user-defined tags that are attached to the secret | `map(string)` | `null` | yes |
| rotation_enabled | Specifies if rotation is set or not | `bool` | `false` | no |
| rotation_lambda_arn | Specifies the ARN of the Lambda function that can rotate the secret. This value is needed only if rotation_enabled is set to true | `string` | `null` | no |
| rotation_after_days | A structure that defines the rotation configuration for this secret. This value is needed only if rotation_enabled is set to true | `number` | `null` | no |
| secret_version_enabled | Specifies if versioning is set or not | `bool` | `false` | no |
| secret_string | Specifies text data that you want to encrypt and store in this version of the secret. This value is needed only if secret_version_enabled is set to true. This is required if secret_binary is not set. | `string` | `null` | no |
| secret_binary | Specifies binary data that you want to encrypt and store in this version of the secret. This value is needed only if secret_version_enabled is set to true. This is required if secret_string is not set. Needs to be encoded to base64. | `string` | `null` | no |
| version_stages | Specifies a list of staging labels that are attached to this version of the secret. This value is needed only if secret_version_enabled is set to true | `list(string)` | `null` | no |



## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the secret |
| rotation_enabled | Whether automatic rotation is enabled for this secret |
| replica | Attributes of a replica are described below |
| version_id | The unique identifier of the version of the secret |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->


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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |

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
| [aws_secretsmanager_secret.sm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.sm_secret_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.sm_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_policy"></a> [custom\_policy](#input\_custom\_policy) | Valid JSON document representing a resource policy | `string` | `"{}"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or Id of the AWS KMS customer master key to encrypt secretsmanager | `string` | `null` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `30` | no |
| <a name="input_replica_kms_key_id"></a> [replica\_kms\_key\_id](#input\_replica\_kms\_key\_id) | ARN, Key ID, or Alias for encrypting secretsmanager replica | `string` | `null` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | Region for replicating the secret | `string` | `null` | no |
| <a name="input_rotation_after_days"></a> [rotation\_after\_days](#input\_rotation\_after\_days) | A structure that defines the rotation configuration for this secret | `number` | `null` | no |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | Specifies if rotation is set or not | `bool` | `false` | no |
| <a name="input_rotation_lambda_arn"></a> [rotation\_lambda\_arn](#input\_rotation\_lambda\_arn) | Specifies the ARN of the Lambda function that can rotate the secret | `string` | `null` | no |
| <a name="input_secret_binary"></a> [secret\_binary](#input\_secret\_binary) | Specifies binary data that you want to encrypt and store in this version of the secret | `string` | `null` | no |
| <a name="input_secret_string"></a> [secret\_string](#input\_secret\_string) | Specifies text data that you want to encrypt and store in this version of the secret | `string` | `null` | no |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | `false` | no |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | n/a | yes |
| <a name="input_secretsmanager_name"></a> [secretsmanager\_name](#input\_secretsmanager\_name) | Name of the new secret | `string` | `null` | no |
| <a name="input_secretsmanager_name_prefix"></a> [secretsmanager\_name\_prefix](#input\_secretsmanager\_name\_prefix) | Creates a unique name beginning with the specified prefix | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of user-defined tags that are attached to the secret | `map(string)` | n/a | yes |
| <a name="input_version_stages"></a> [version\_stages](#input\_version\_stages) | Specifies a list of staging labels that are attached to this version of the secret | `list(string)` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the secret |
| <a name="output_aws_secretsmanager_secret"></a> [aws\_secretsmanager\_secret](#output\_aws\_secretsmanager\_secret) | Map of aws\_secretsmanager\_secret object |
| <a name="output_aws_secretsmanager_secret_rotation"></a> [aws\_secretsmanager\_secret\_rotation](#output\_aws\_secretsmanager\_secret\_rotation) | Map of aws\_secretsmanager\_secret object |
| <a name="output_aws_secretsmanager_secret_version"></a> [aws\_secretsmanager\_secret\_version](#output\_aws\_secretsmanager\_secret\_version) | Map of aws\_secretsmanager\_secret object |
| <a name="output_replica"></a> [replica](#output\_replica) | Attributes of a replica are described below |
| <a name="output_rotation_enabled"></a> [rotation\_enabled](#output\_rotation\_enabled) | Whether automatic rotation is enabled for this secret |
| <a name="output_secret_version_enabled"></a> [secret\_version\_enabled](#output\_secret\_version\_enabled) | The version of the secret |
| <a name="output_version_id"></a> [version\_id](#output\_version\_id) | The unique identifier of the version of the secret |

<!-- END_TF_DOCS -->