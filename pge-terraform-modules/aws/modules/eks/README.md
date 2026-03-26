<!-- BEGIN_TF_DOCS -->
# AWS eks cluster with  managed node group creation
This module will create eks and  managed groups.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

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
| <a name="module_acm_public_certificate"></a> [acm\_public\_certificate](#module\_acm\_public\_certificate) | app.terraform.io/pgetech/acm/aws | 0.1.2 |
| <a name="module_aws_iam"></a> [aws\_iam](#module\_aws\_iam) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_aws_iam_role"></a> [aws\_iam\_role](#module\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ./modules/internal/bootstrap/ | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | app.terraform.io/pgetech/kms/aws | 0.1.4 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | ./user-data | n/a |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.eks_access_entry_codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.eks_access_policy_association_codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.before_compute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.eks-nodegroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_policy.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.auto](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_auto_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.auto](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_auto_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_auto_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group_rule.cluster_security_group_ingress_rule1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_auto_mode](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.node_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Route53 account number | `string` | `"514712703977"` | no |
| <a name="input_acm_certificate_id"></a> [acm\_certificate\_id](#input\_acm\_certificate\_id) | The ARN of the ACM certificate to use for the load balancer | `string` | `""` | no |
| <a name="input_addon_version"></a> [addon\_version](#input\_addon\_version) | Specifies the number of days you want to retain log events in the specified log group | `number` | `null` | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values | `string` | `""` | no |
| <a name="input_argocd_git_auth"></a> [argocd\_git\_auth](#input\_argocd\_git\_auth) | Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the ArgoCD repository | `string` | n/a | yes |
| <a name="input_attach_cluster_encryption_policy"></a> [attach\_cluster\_encryption\_policy](#input\_attach\_cluster\_encryption\_policy) | Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided | `bool` | `true` | no |
| <a name="input_auto_node_iam_role_additional_policies"></a> [auto\_node\_iam\_role\_additional\_policies](#input\_auto\_node\_iam\_role\_additional\_policies) | Additional policies to be added to the EKS Auto node IAM role | `map(string)` | `{}` | no |
| <a name="input_auto_node_iam_role_description"></a> [auto\_node\_iam\_role\_description](#input\_auto\_node\_iam\_role\_description) | Description of the EKS Auto node IAM role | `string` | `null` | no |
| <a name="input_auto_node_iam_role_name"></a> [auto\_node\_iam\_role\_name](#input\_auto\_node\_iam\_role\_name) | Name to use on the EKS Auto node IAM role created | `string` | `null` | no |
| <a name="input_auto_node_iam_role_path"></a> [auto\_node\_iam\_role\_path](#input\_auto\_node\_iam\_role\_path) | The EKS Auto node IAM role path | `string` | `null` | no |
| <a name="input_auto_node_iam_role_permissions_boundary"></a> [auto\_node\_iam\_role\_permissions\_boundary](#input\_auto\_node\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role | `string` | `null` | no |
| <a name="input_auto_node_iam_role_tags"></a> [auto\_node\_iam\_role\_tags](#input\_auto\_node\_iam\_role\_tags) | A map of additional tags to add to the EKS Auto node IAM role created | `map(string)` | `{}` | no |
| <a name="input_auto_node_iam_role_use_name_prefix"></a> [auto\_node\_iam\_role\_use\_name\_prefix](#input\_auto\_node\_iam\_role\_use\_name\_prefix) | Determines whether the EKS Auto node IAM role name (`auto_node_iam_role_use_name_prefix`) is used as a prefix | `bool` | `true` | no |
| <a name="input_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#input\_aws\_ebs\_csi\_driver) | aws ebs csi driver name | `string` | `"aws-ebs-csi-driver"` | no |
| <a name="input_aws_kms_key_arn"></a> [aws\_kms\_key\_arn](#input\_aws\_kms\_key\_arn) | KMS encryption key ARN for the EKS cluster. If not provided, a new KMS key will be created automatically (requires kms\_role to be specified) | `string` | `null` | no |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume for Route53 | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | `"eks-test"` | no |
| <a name="input_bootstrap_extra_args"></a> [bootstrap\_extra\_args](#input\_bootstrap\_extra\_args) | Additional arguments passed to the bootstrap script. When `ami_type` = `BOTTLEROCKET_*`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data | `string` | `null` | no |
| <a name="input_bootstrap_self_managed_addons"></a> [bootstrap\_self\_managed\_addons](#input\_bootstrap\_self\_managed\_addons) | Indicates whether or not to bootstrap self-managed addons after the cluster has been created | `bool` | `true` | no |
| <a name="input_cloudinit_post_nodeadm"></a> [cloudinit\_post\_nodeadm](#input\_cloudinit\_post\_nodeadm) | Array of cloud-init document parts that are created after the nodeadm document part | <pre>list(object({<br/>    content      = string<br/>    content_type = optional(string)<br/>    filename     = optional(string)<br/>    merge_type   = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_cloudinit_pre_nodeadm"></a> [cloudinit\_pre\_nodeadm](#input\_cloudinit\_pre\_nodeadm) | Array of cloud-init document parts that are created before the nodeadm document part | <pre>list(object({<br/>    content      = string<br/>    content_type = optional(string)<br/>    filename     = optional(string)<br/>    merge_type   = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | `{}` | no |
| <a name="input_cluster_addons_timeouts"></a> [cluster\_addons\_timeouts](#input\_cluster\_addons\_timeouts) | Create, update, and delete timeout configurations for the cluster addons | `map(string)` | `{}` | no |
| <a name="input_cluster_auth_base64"></a> [cluster\_auth\_base64](#input\_cluster\_auth\_base64) | Base64 encoded CA of associated EKS cluster | `string` | `null` | no |
| <a name="input_cluster_compute_config"></a> [cluster\_compute\_config](#input\_cluster\_compute\_config) | Configuration block for the cluster compute configuration | `any` | `{}` | no |
| <a name="input_cluster_create_timeout"></a> [cluster\_create\_timeout](#input\_cluster\_create\_timeout) | Timeout value when creating the EKS cluster. | `string` | `"30m"` | no |
| <a name="input_cluster_delete_timeout"></a> [cluster\_delete\_timeout](#input\_cluster\_delete\_timeout) | Timeout value when deleting the EKS cluster. | `string` | `"15m"` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}` | `any` | <pre>{<br/>  "resources": [<br/>    "secrets"<br/>  ]<br/>}</pre> | no |
| <a name="input_cluster_encryption_policy_description"></a> [cluster\_encryption\_policy\_description](#input\_cluster\_encryption\_policy\_description) | Description of the cluster encryption policy created | `string` | `"Cluster encryption policy to allow cluster role to utilize CMK provided"` | no |
| <a name="input_cluster_encryption_policy_name"></a> [cluster\_encryption\_policy\_name](#input\_cluster\_encryption\_policy\_name) | Name to use on cluster encryption policy created | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_path"></a> [cluster\_encryption\_policy\_path](#input\_cluster\_encryption\_policy\_path) | Cluster encryption policy path | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_tags"></a> [cluster\_encryption\_policy\_tags](#input\_cluster\_encryption\_policy\_tags) | A map of additional tags to add to the cluster encryption policy created | `map(string)` | `{}` | no |
| <a name="input_cluster_encryption_policy_use_name_prefix"></a> [cluster\_encryption\_policy\_use\_name\_prefix](#input\_cluster\_encryption\_policy\_use\_name\_prefix) | Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint of associated EKS cluster | `string` | `null` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of your EKS Cluster | `string` | n/a | yes |
| <a name="input_cluster_service_cidr"></a> [cluster\_service\_cidr](#input\_cluster\_service\_cidr) | The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself | `string` | `null` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | service ipv4 cidr for the kubernetes cluster | `string` | `null` | no |
| <a name="input_cluster_update_timeout"></a> [cluster\_update\_timeout](#input\_cluster\_update\_timeout) | Timeout value when updating the EKS cluster. | `string` | `"60m"` | no |
| <a name="input_cluster_upgrade_policy"></a> [cluster\_upgrade\_policy](#input\_cluster\_upgrade\_policy) | Configuration block for the cluster upgrade policy | `any` | `{}` | no |
| <a name="input_codebuild_git_auth"></a> [codebuild\_git\_auth](#input\_codebuild\_git\_auth) | Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the EKS bootstrap repository | `string` | n/a | yes |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | The CPU options for the instance | `map(string)` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Use to toggle creation of sources by this module | `bool` | `true` | no |
| <a name="input_create_auto_iam_role"></a> [create\_auto\_iam\_role](#input\_create\_auto\_iam\_role) | Determines whether an IAM role is created for the cluster | `bool` | `true` | no |
| <a name="input_create_auto_node_iam_role"></a> [create\_auto\_node\_iam\_role](#input\_create\_auto\_node\_iam\_role) | Determines whether an EKS Auto node IAM role is created | `bool` | `true` | no |
| <a name="input_create_cloudwatch_agent"></a> [create\_cloudwatch\_agent](#input\_create\_cloudwatch\_agent) | Create cloudwatch agent for eks cluster | `bool` | `false` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Determines whether to create a launch template or not. If set to `false`, EKS will use its own default launch template | `bool` | `true` | no |
| <a name="input_create_metrics_server"></a> [create\_metrics\_server](#input\_create\_metrics\_server) | Create metrics server adddon for eks cluster | `bool` | `true` | no |
| <a name="input_custom_identity"></a> [custom\_identity](#input\_custom\_identity) | Name of IAM role | `string` | `""` | no |
| <a name="input_custom_identity_additional_policy_arns"></a> [custom\_identity\_additional\_policy\_arns](#input\_custom\_identity\_additional\_policy\_arns) | ARNs of additional policies to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_custom_identity_associations"></a> [custom\_identity\_associations](#input\_custom\_identity\_associations) | Map of Pod Identity associations to be created (map of maps) | `any` | `{}` | no |
| <a name="input_custom_identity_override_policy_documents"></a> [custom\_identity\_override\_policy\_documents](#input\_custom\_identity\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_source_policy_documents"></a> [custom\_identity\_source\_policy\_documents](#input\_custom\_identity\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_trust_policy_conditions"></a> [custom\_identity\_trust\_policy\_conditions](#input\_custom\_identity\_trust\_policy\_conditions) | A list of conditions to add to the role trust policy | `any` | `[]` | no |
| <a name="input_custom_repo_branch"></a> [custom\_repo\_branch](#input\_custom\_repo\_branch) | Custom repository branch for the bootstrap process | `string` | n/a | yes |
| <a name="input_custom_repo_url"></a> [custom\_repo\_url](#input\_custom\_repo\_url) | Custom repository URL for the bootstrap process | `string` | n/a | yes |
| <a name="input_dataplane_wait_duration"></a> [dataplane\_wait\_duration](#input\_dataplane\_wait\_duration) | Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed node group(s), self-managed node group(s), Fargate profile(s)) | `string` | `"30s"` | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of self-managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | `{}` | no |
| <a name="input_enable_auto_mode_custom_tags"></a> [enable\_auto\_mode\_custom\_tags](#input\_enable\_auto\_mode\_custom\_tags) | Determines whether to enable permissions for custom tags resources created by EKS Auto Mode | `bool` | `true` | no |
| <a name="input_enable_bootstrap_user_data"></a> [enable\_bootstrap\_user\_data](#input\_enable\_bootstrap\_user\_data) | Determines whether the bootstrap configurations are populated within the user data template. Only valid when using a custom AMI via `ami_id` | `bool` | `false` | no |
| <a name="input_enable_security_groups_for_pods"></a> [enable\_security\_groups\_for\_pods](#input\_enable\_security\_groups\_for\_pods) | Determines whether to add the necessary IAM permission policy for security groups for pods | `bool` | `true` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | The hosted zone ID of the domain | `string` | n/a | yes |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_auto_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | The IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_k8s-version"></a> [k8s-version](#input\_k8s-version) | Required K8s version | `string` | n/a | yes |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | The kernel ID | `string` | `null` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. Required when aws\_kms\_key\_arn is not provided (i.e., when a new KMS key will be created) | `string` | `null` | no |
| <a name="input_launch_template_default_version"></a> [launch\_template\_default\_version](#input\_launch\_template\_default\_version) | Default version of the launch template | `string` | `null` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | Description of the launch template | `string` | `null` | no |
| <a name="input_launch_template_id"></a> [launch\_template\_id](#input\_launch\_template\_id) | The ID of an existing launch template to use. Required when `create_launch_template` = `false` and `use_custom_launch_template` = `true` | `string` | `""` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Name of launch template to be created | `string` | `null` | no |
| <a name="input_launch_template_use_name_prefix"></a> [launch\_template\_use\_name\_prefix](#input\_launch\_template\_use\_name\_prefix) | Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix | `bool` | `true` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version number. The default is `$Default` | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EKS managed node group | `string` | `""` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id3_name"></a> [parameter\_subnet\_id3\_name](#input\_parameter\_subnet\_id3\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based | `string` | `"linux"` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of managed IAM policies to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_post_bootstrap_user_data"></a> [post\_bootstrap\_user\_data](#input\_post\_bootstrap\_user\_data) | User data that is appended to the user data script after of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*` | `string` | `null` | no |
| <a name="input_pre_bootstrap_user_data"></a> [pre\_bootstrap\_user\_data](#input\_pre\_bootstrap\_user\_data) | User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*` | `string` | `null` | no |
| <a name="input_prefix_separator"></a> [prefix\_separator](#input\_prefix\_separator) | The separator to use between the prefix and the generated timestamp for resource names | `string` | `"-"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | (Required) List of strings with resources to be encrypted. | `list(string)` | <pre>[<br/>  "secrets"<br/>]</pre> | no |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "eks.amazonaws.com"<br/>]</pre> | no |
| <a name="input_role_service_managed"></a> [role\_service\_managed](#input\_role\_service\_managed) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "ec2.amazonaws.com"<br/>]</pre> | no |
| <a name="input_selected_nodegroup"></a> [selected\_nodegroup](#input\_selected\_nodegroup) | The key of the node group in eks\_managed\_node\_groups to use for launch template settings. E.g., 'launch\_template\_nodegroup' or 'launch\_template\_nodegroup\_multi' | `string` | `"launch_template_nodegroup"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (optional) Tags to assign to the cluster | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the node group | `map(string)` | <pre>{<br/>  "create": "30m",<br/>  "delete": "30m",<br/>  "update": "30m"<br/>}</pre> | no |
| <a name="input_update_launch_template_default_version"></a> [update\_launch\_template\_default\_version](#input\_update\_launch\_template\_default\_version) | Whether to update the launch templates default version on each update. Conflicts with `launch_template_default_version` | `bool` | `true` | no |
| <a name="input_use_ami_latest"></a> [use\_ami\_latest](#input\_use\_ami\_latest) | Set this parameter to true during upgrade to create parallel nodegroups with latest version | `bool` | `false` | no |
| <a name="input_user_data_template_path"></a> [user\_data\_template\_path](#input\_user\_data\_template\_path) | Path to a local, custom user data template file to use when rendering user data | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate used for the ingress-nginx controller |
| <a name="output_acm_public_certificate_arn"></a> [acm\_public\_certificate\_arn](#output\_acm\_public\_certificate\_arn) | ACM Public Certificate |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons enabled |
| <a name="output_cluster_all"></a> [cluster\_all](#output\_cluster\_all) | all eks cluster attribute output |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The endpoint for your EKS Kubernetes API. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the cluster |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the cluster |
| <a name="output_generated_roles_config"></a> [generated\_roles\_config](#output\_generated\_roles\_config) | generated\_roles\_config |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used for EKS cluster encryption |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the KMS key created by this module (null if using externally provided key) |
| <a name="output_node_group"></a> [node\_group](#output\_node\_group) | node groups |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Base64 encoded user data rendered for the provided inputs |

<!-- END_TF_DOCS -->