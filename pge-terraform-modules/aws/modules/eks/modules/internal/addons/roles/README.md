<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

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
| [aws_eks_pod_identity_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.efs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.external_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lb_controller_targetgroup_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.efs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.external_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lb_controller_targetgroup_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.efs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lb_controller_targetgroup_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | ARNs of additional policies to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_association_defaults"></a> [association\_defaults](#input\_association\_defaults) | Default values used across all Pod Identity associations created unless a more specific value is provided | `map(string)` | `{}` | no |
| <a name="input_associations"></a> [associations](#input\_associations) | Map of Pod Identity associations to be created (map of maps) | `any` | `{}` | no |
| <a name="input_attach_aws_ebs_csi_policy"></a> [attach\_aws\_ebs\_csi\_policy](#input\_attach\_aws\_ebs\_csi\_policy) | Determines whether to attach the EBS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_efs_csi_policy"></a> [attach\_aws\_efs\_csi\_policy](#input\_attach\_aws\_efs\_csi\_policy) | Determines whether to attach the EFS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_lb_controller_policy"></a> [attach\_aws\_lb\_controller\_policy](#input\_attach\_aws\_lb\_controller\_policy) | Determines whether to attach the AWS Load Balancer Controller policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_lb_controller_targetgroup_binding_only_policy"></a> [attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy](#input\_attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy) | Determines whether to attach the AWS Load Balancer Controller policy for the TargetGroupBinding only | `bool` | `false` | no |
| <a name="input_attach_aws_vpc_cni_policy"></a> [attach\_aws\_vpc\_cni\_policy](#input\_attach\_aws\_vpc\_cni\_policy) | Determines whether to attach the VPC CNI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_cluster_autoscaler_policy"></a> [attach\_cluster\_autoscaler\_policy](#input\_attach\_cluster\_autoscaler\_policy) | Determines whether to attach the Cluster Autoscaler IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_custom_policy"></a> [attach\_custom\_policy](#input\_attach\_custom\_policy) | Determines whether to attach the custom IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_external_dns_policy"></a> [attach\_external\_dns\_policy](#input\_attach\_external\_dns\_policy) | Determines whether to attach the External DNS IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_external_secrets_policy"></a> [attach\_external\_secrets\_policy](#input\_attach\_external\_secrets\_policy) | Determines whether to attach the External Secrets policy to the role | `bool` | `false` | no |
| <a name="input_aws_ebs_csi_kms_arns"></a> [aws\_ebs\_csi\_kms\_arns](#input\_aws\_ebs\_csi\_kms\_arns) | KMS key ARNs to allow EBS CSI to manage encrypted volumes | `list(string)` | `[]` | no |
| <a name="input_aws_ebs_csi_policy_name"></a> [aws\_ebs\_csi\_policy\_name](#input\_aws\_ebs\_csi\_policy\_name) | Custom name of the EBS CSI IAM policy | `string` | `null` | no |
| <a name="input_aws_efs_csi_policy_name"></a> [aws\_efs\_csi\_policy\_name](#input\_aws\_efs\_csi\_policy\_name) | Custom name of the EFS CSI IAM policy | `string` | `null` | no |
| <a name="input_aws_lb_controller_policy_name"></a> [aws\_lb\_controller\_policy\_name](#input\_aws\_lb\_controller\_policy\_name) | Custom name of the AWS Load Balancer Controller IAM policy | `string` | `null` | no |
| <a name="input_aws_lb_controller_targetgroup_arns"></a> [aws\_lb\_controller\_targetgroup\_arns](#input\_aws\_lb\_controller\_targetgroup\_arns) | List of Target groups ARNs using Load Balancer Controller | `list(string)` | `[]` | no |
| <a name="input_aws_lb_controller_targetgroup_only_policy_name"></a> [aws\_lb\_controller\_targetgroup\_only\_policy\_name](#input\_aws\_lb\_controller\_targetgroup\_only\_policy\_name) | Custom name of the AWS Load Balancer Controller IAM policy for the TargetGroupBinding only | `string` | `null` | no |
| <a name="input_aws_vpc_cni_enable_ipv4"></a> [aws\_vpc\_cni\_enable\_ipv4](#input\_aws\_vpc\_cni\_enable\_ipv4) | Determines whether to enable IPv4 permissions for VPC CNI policy | `bool` | `false` | no |
| <a name="input_aws_vpc_cni_policy_name"></a> [aws\_vpc\_cni\_policy\_name](#input\_aws\_vpc\_cni\_policy\_name) | Custom name of the VPC CNI IAM policy | `string` | `null` | no |
| <a name="input_cluster_autoscaler_cluster_names"></a> [cluster\_autoscaler\_cluster\_names](#input\_cluster\_autoscaler\_cluster\_names) | List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy | `list(string)` | `[]` | no |
| <a name="input_cluster_autoscaler_policy_name"></a> [cluster\_autoscaler\_policy\_name](#input\_cluster\_autoscaler\_policy\_name) | Custom name of the Cluster Autoscaler IAM policy | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cluster_autoscaler_role"></a> [create\_cluster\_autoscaler\_role](#input\_create\_cluster\_autoscaler\_role) | Determines whether to attach the Cluster Autoscaler IAM policy to the role | `bool` | `false` | no |
| <a name="input_create_efs_csi"></a> [create\_efs\_csi](#input\_create\_efs\_csi) | Determines whether to create the efs csi IAM role | `bool` | `false` | no |
| <a name="input_create_external_dns"></a> [create\_external\_dns](#input\_create\_external\_dns) | Determines whether to create the external dns IAM role | `bool` | `false` | no |
| <a name="input_create_external_secrets"></a> [create\_external\_secrets](#input\_create\_external\_secrets) | Determines whether to create the external secrets IAM role | `bool` | `false` | no |
| <a name="input_create_lb_controller"></a> [create\_lb\_controller](#input\_create\_lb\_controller) | Determines whether to create the lb controller IAM Role | `bool` | `false` | no |
| <a name="input_create_vpc_cni"></a> [create\_vpc\_cni](#input\_create\_vpc\_cni) | Determines whether to create VPC CNI IAM Role | `bool` | `false` | no |
| <a name="input_custom_policy_description"></a> [custom\_policy\_description](#input\_custom\_policy\_description) | Description of the custom IAM policy | `string` | `"Custom IAM Policy"` | no |
| <a name="input_description"></a> [description](#input\_description) | IAM Role description | `string` | `null` | no |
| <a name="input_external_dns_hosted_zone_arns"></a> [external\_dns\_hosted\_zone\_arns](#input\_external\_dns\_hosted\_zone\_arns) | Route53 hosted zone ARNs to allow External DNS to manage records | `list(string)` | `[]` | no |
| <a name="input_external_dns_policy_name"></a> [external\_dns\_policy\_name](#input\_external\_dns\_policy\_name) | Custom name of the External DNS IAM policy | `string` | `null` | no |
| <a name="input_external_secrets_create_permission"></a> [external\_secrets\_create\_permission](#input\_external\_secrets\_create\_permission) | Determines whether External Secrets has permission to create/delete secrets | `bool` | `false` | no |
| <a name="input_external_secrets_kms_key_arns"></a> [external\_secrets\_kms\_key\_arns](#input\_external\_secrets\_kms\_key\_arns) | List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_policy_name"></a> [external\_secrets\_policy\_name](#input\_external\_secrets\_policy\_name) | Custom name of the External Secrets IAM policy | `string` | `null` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum CLI/API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of IAM role | `string` | `""` | no |
| <a name="input_override_policy_documents"></a> [override\_policy\_documents](#input\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_path"></a> [path](#input\_path) | Path of IAM role | `string` | `"/"` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | Permissions boundary ARN to use for IAM role | `string` | `null` | no |
| <a name="input_policy_name_prefix"></a> [policy\_name\_prefix](#input\_policy\_name\_prefix) | IAM policy name prefix | `string` | `"AmazonEKS_"` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `[]` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_trust_policy_conditions"></a> [trust\_policy\_conditions](#input\_trust\_policy\_conditions) | A list of conditions to add to the role trust policy | `any` | `[]` | no |
| <a name="input_trust_policy_statements"></a> [trust\_policy\_statements](#input\_trust\_policy\_statements) | A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for the role trust policy | `any` | `[]` | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Determines whether the role name and policy name(s) are used as a prefix | `string` | `true` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_associations"></a> [associations](#output\_associations) | Map of Pod Identity associations created |
| <a name="output_iam_policy_arn"></a> [iam\_policy\_arn](#output\_iam\_policy\_arn) | The ARN assigned by AWS to this policy |
| <a name="output_iam_policy_id"></a> [iam\_policy\_id](#output\_iam\_policy\_id) | The policy's ID |
| <a name="output_iam_policy_name"></a> [iam\_policy\_name](#output\_iam\_policy\_name) | Name of IAM policy |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of IAM role |
| <a name="output_iam_role_path"></a> [iam\_role\_path](#output\_iam\_role\_path) | Path of IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Unique ID of IAM role |

<!-- END_TF_DOCS -->