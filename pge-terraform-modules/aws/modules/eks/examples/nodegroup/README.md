<!-- BEGIN_TF_DOCS -->
# Terraform usage example which creates eks multiple node groups in AWS
This module will create eks managed groups for ec2 instances.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.1 |

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
| <a name="module_addon-resources"></a> [addon-resources](#module\_addon-resources) | ../../modules/kubernetes-addons | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.override](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | <pre>object({<br/>    clusteradmins = list(string)<br/>    clustereditors = list(object({<br/>      role       = string<br/>      namespaces = list(string)<br/>    }))<br/>    clusterviewers = list(object({<br/>      role       = string<br/>      namespaces = list(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Route53 account number | `string` | `"514712703977"` | no |
| <a name="input_addon_configuration_values"></a> [addon\_configuration\_values](#input\_addon\_configuration\_values) | Configuration values for the EKS addon | `map(any)` | `{}` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Custom AMI ID to use for the EKS Node Group | `string` | `""` | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values | `string` | `""` | no |
| <a name="input_argocd_git_auth"></a> [argocd\_git\_auth](#input\_argocd\_git\_auth) | Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the ArgoCD repository | `string` | n/a | yes |
| <a name="input_association_defaults"></a> [association\_defaults](#input\_association\_defaults) | Default values used across all Pod Identity associations created unless a more specific value is provided | `map(string)` | `{}` | no |
| <a name="input_associations"></a> [associations](#input\_associations) | Map of Pod Identity associations to be created (map of maps) | `any` | `{}` | no |
| <a name="input_attach_aws_vpc_cni_policy"></a> [attach\_aws\_vpc\_cni\_policy](#input\_attach\_aws\_vpc\_cni\_policy) | Determines whether to attach the VPC CNI IAM policy to the role | `bool` | `false` | no |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume for Route53 operations | `string` | `"CloudAdmin"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | `"eks-test"` | no |
| <a name="input_aws_vpc_cni_enable_ipv4"></a> [aws\_vpc\_cni\_enable\_ipv4](#input\_aws\_vpc\_cni\_enable\_ipv4) | Determines whether to enable IPv4 permissions for VPC CNI policy | `bool` | `false` | no |
| <a name="input_aws_vpc_cni_policy_name"></a> [aws\_vpc\_cni\_policy\_name](#input\_aws\_vpc\_cni\_policy\_name) | Custom name of the VPC CNI IAM policy | `string` | `null` | no |
| <a name="input_bootstrap_self_managed_addons"></a> [bootstrap\_self\_managed\_addons](#input\_bootstrap\_self\_managed\_addons) | Bootstrap the CCOE managed addons, set to false if you are not using them | `bool` | `true` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | `{}` | no |
| <a name="input_cluster_addons_timeouts"></a> [cluster\_addons\_timeouts](#input\_cluster\_addons\_timeouts) | Create, update, and delete timeout configurations for the cluster addons | `map(string)` | `{}` | no |
| <a name="input_cluster_autoscaler_cluster_names"></a> [cluster\_autoscaler\_cluster\_names](#input\_cluster\_autoscaler\_cluster\_names) | List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy | `list(string)` | `[]` | no |
| <a name="input_cluster_dimensions"></a> [cluster\_dimensions](#input\_cluster\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>comparison\_operator is the type of comparison operation. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>Specify an empty map if you do not want to notify Cluster level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of your EKS Cluster | `string` | n/a | yes |
| <a name="input_cluster_service_cidr"></a> [cluster\_service\_cidr](#input\_cluster\_service\_cidr) | The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself | `string` | `""` | no |
| <a name="input_codebuild_git_auth"></a> [codebuild\_git\_auth](#input\_codebuild\_git\_auth) | ARN of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the EKS bootstrap repository | `string` | n/a | yes |
| <a name="input_compute_type_codebuild"></a> [compute\_type\_codebuild](#input\_compute\_type\_codebuild) | Information about the compute resources the build project will use in codebuild project | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_create_aws_for_fluentbit_resources"></a> [create\_aws\_for\_fluentbit\_resources](#input\_create\_aws\_for\_fluentbit\_resources) | Determines whether to create aws for fluentbit IAM Role | `bool` | `false` | no |
| <a name="input_create_cloudwatch_agent"></a> [create\_cloudwatch\_agent](#input\_create\_cloudwatch\_agent) | Create cloudwatch agent for eks cluster | `bool` | n/a | yes |
| <a name="input_create_cluster_autoscaler_resources"></a> [create\_cluster\_autoscaler\_resources](#input\_create\_cluster\_autoscaler\_resources) | Determines whether to attach the Cluster Autoscaler IAM policy to the role | `bool` | `false` | no |
| <a name="input_create_custom_role"></a> [create\_custom\_role](#input\_create\_custom\_role) | Determines whether to create the custom IAM role | `bool` | `false` | no |
| <a name="input_create_ebs_csi_resources"></a> [create\_ebs\_csi\_resources](#input\_create\_ebs\_csi\_resources) | Determines whether to create the ebs csi IAM role | `bool` | `false` | no |
| <a name="input_create_efs_csi_resources"></a> [create\_efs\_csi\_resources](#input\_create\_efs\_csi\_resources) | Determines whether to create the efs csi IAM role | `bool` | `false` | no |
| <a name="input_create_eks_dashboard"></a> [create\_eks\_dashboard](#input\_create\_eks\_dashboard) | eks dashboard true/false | `bool` | n/a | yes |
| <a name="input_create_karpenter_resources"></a> [create\_karpenter\_resources](#input\_create\_karpenter\_resources) | Create karpenter adddon resources, node role , controller role, queue for eks cluster | `bool` | `false` | no |
| <a name="input_create_loki_resources"></a> [create\_loki\_resources](#input\_create\_loki\_resources) | Create loki resources for eks cluster | `bool` | `false` | no |
| <a name="input_create_mimir_resources"></a> [create\_mimir\_resources](#input\_create\_mimir\_resources) | Create mimir resources for eks cluster | `bool` | `false` | no |
| <a name="input_create_tempo_resources"></a> [create\_tempo\_resources](#input\_create\_tempo\_resources) | Create tempo resources for eks cluster | `bool` | `false` | no |
| <a name="input_create_vpc_cni_resources"></a> [create\_vpc\_cni\_resources](#input\_create\_vpc\_cni\_resources) | Determines whether to create VPC CNI IAM Role | `bool` | `false` | no |
| <a name="input_custom_identity"></a> [custom\_identity](#input\_custom\_identity) | Name of IAM role | `string` | `""` | no |
| <a name="input_custom_identity_additional_policy_arns"></a> [custom\_identity\_additional\_policy\_arns](#input\_custom\_identity\_additional\_policy\_arns) | ARNs of additional policies to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_custom_identity_associations"></a> [custom\_identity\_associations](#input\_custom\_identity\_associations) | Map of Pod Identity associations to be created (map of maps) | `any` | `{}` | no |
| <a name="input_custom_identity_override_policy_documents"></a> [custom\_identity\_override\_policy\_documents](#input\_custom\_identity\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_source_policy_documents"></a> [custom\_identity\_source\_policy\_documents](#input\_custom\_identity\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_trust_policy_conditions"></a> [custom\_identity\_trust\_policy\_conditions](#input\_custom\_identity\_trust\_policy\_conditions) | A list of conditions to add to the role trust policy | `any` | `[]` | no |
| <a name="input_custom_repo_branch"></a> [custom\_repo\_branch](#input\_custom\_repo\_branch) | name of the branch to be used for your own Argo CD repository | `string` | `"main"` | no |
| <a name="input_custom_repo_url"></a> [custom\_repo\_url](#input\_custom\_repo\_url) | Custom repository URL for the bootstrap process | `string` | n/a | yes |
| <a name="input_domain_env"></a> [domain\_env](#input\_domain\_env) | Enable external dns add-on | `string` | `"nonprod"` | no |
| <a name="input_enable_aws_cloudwatch_metrics"></a> [enable\_aws\_cloudwatch\_metrics](#input\_enable\_aws\_cloudwatch\_metrics) | Enable AWS CloudWatch Metrics add-on for Container Insights | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Load Balancer Controller add-on | `bool` | `false` | no |
| <a name="input_encrypt_ebs_csi"></a> [encrypt\_ebs\_csi](#input\_encrypt\_ebs\_csi) | Determines whether to encrypt EBS volumes created by the EBS CSI driver | `bool` | `false` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | Enter the KMS key arn for encryption - uses for both codepipeline and codebuild | `string` | `null` | no |
| <a name="input_environment_image_codebuild"></a> [environment\_image\_codebuild](#input\_environment\_image\_codebuild) | Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest). | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_type_codebuild"></a> [environment\_type\_codebuild](#input\_environment\_type\_codebuild) | Type of build environment to use for codebuild project related builds. Valid values: LINUX\_CONTAINER, LINUX\_GPU\_CONTAINER, WINDOWS\_CONTAINER (deprecated), WINDOWS\_SERVER\_2019\_CONTAINER, ARM\_CONTAINER. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_variables_codebuild_stage"></a> [environment\_variables\_codebuild\_stage](#input\_environment\_variables\_codebuild\_stage) | Provide the list of optional environment variables required for codebuild stage | `list(any)` | `[]` | no |
| <a name="input_external_secrets_kms_key_arns"></a> [external\_secrets\_kms\_key\_arns](#input\_external\_secrets\_kms\_key\_arns) | List of secrets kms key arns | `list(string)` | `[]` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | Route53 hosted zone name | `string` | n/a | yes |
| <a name="input_k8s-version"></a> [k8s-version](#input\_k8s-version) | Required K8s version | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key | `string` | n/a | yes |
| <a name="input_kube_proxy"></a> [kube\_proxy](#input\_kube\_proxy) | kube proxy name | `string` | `"kube-proxy"` | no |
| <a name="input_namespace_dimensions"></a> [namespace\_dimensions](#input\_namespace\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the namespace name to be notified. <br>Specify an empty map if you do not want to notify Namespace level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_parameter_subnet_id3_name"></a> [parameter\_subnet\_id3\_name](#input\_parameter\_subnet\_id3\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | `""` | no |
| <a name="input_pod_dimensions"></a> [pod\_dimensions](#input\_pod\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the pod to be notified runs. <br>Pod is the pod name to be notified. <br>Specify an empty map if you do not want to perform Pod-level alert notifications. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>    pod                 = string<br/>  }))</pre> | `{}` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue | `string` | `null` | no |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "eks.amazonaws.com"<br/>]</pre> | no |
| <a name="input_role_service_managed"></a> [role\_service\_managed](#input\_role\_service\_managed) | Aws service of the iam role | `list(string)` | <pre>[<br/>  "ec2.amazonaws.com"<br/>]</pre> | no |
| <a name="input_service_dimensions"></a> [service\_dimensions](#input\_service\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the notification target Service operates. <br>Service is the Pod name to be notified. <br>Specify an empty map if you do not want to notify Service level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>    service             = string<br/>  }))</pre> | `{}` | no |
| <a name="input_sns-topic"></a> [sns-topic](#input\_sns-topic) | input email for alarm notification | `string` | `""` | no |
| <a name="input_use_ami_latest"></a> [use\_ami\_latest](#input\_use\_ami\_latest) | Set this parameter to true during upgrade to create parallel nodegroups with latest version | `bool` | `false` | no |
| <a name="input_user"></a> [user](#input\_user) | User id for aws session | `string` | `"rh1b"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_public_certificate_arn"></a> [acm\_public\_certificate\_arn](#output\_acm\_public\_certificate\_arn) | ACM Public Certificate |
| <a name="output_aws_lb_controller_pod_identity_role"></a> [aws\_lb\_controller\_pod\_identity\_role](#output\_aws\_lb\_controller\_pod\_identity\_role) | n/a |
| <a name="output_cluster-autoscaler-role"></a> [cluster-autoscaler-role](#output\_cluster-autoscaler-role) | n/a |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | The status of addons |
| <a name="output_cluster_id_all"></a> [cluster\_id\_all](#output\_cluster\_id\_all) | EKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_custom_pod_identity_role"></a> [custom\_pod\_identity\_role](#output\_custom\_pod\_identity\_role) | n/a |
| <a name="output_ebs_csi_kms_key_arn"></a> [ebs\_csi\_kms\_key\_arn](#output\_ebs\_csi\_kms\_key\_arn) | ARN of the KMS key for EBS CSI driver to encrypt EBS volumes it creates |
| <a name="output_external_secrets_pod_identity_role"></a> [external\_secrets\_pod\_identity\_role](#output\_external\_secrets\_pod\_identity\_role) | n/a |
| <a name="output_loki_chunks_bucket_arn"></a> [loki\_chunks\_bucket\_arn](#output\_loki\_chunks\_bucket\_arn) | s3 ARN. Will be of format arn:aws:s3:::bucketname |
| <a name="output_loki_chunks_bucket_name"></a> [loki\_chunks\_bucket\_name](#output\_loki\_chunks\_bucket\_name) | s3 bucket name |
| <a name="output_loki_ruler_bucket_arn"></a> [loki\_ruler\_bucket\_arn](#output\_loki\_ruler\_bucket\_arn) | s3 ARN. Will be of format arn:aws:s3:::bucketname |
| <a name="output_loki_ruler_bucket_name"></a> [loki\_ruler\_bucket\_name](#output\_loki\_ruler\_bucket\_name) | s3 bucket name |
| <a name="output_mimir_blocks_bucket_arn"></a> [mimir\_blocks\_bucket\_arn](#output\_mimir\_blocks\_bucket\_arn) | S3 ARN for Mimir blocks storage. |
| <a name="output_mimir_blocks_bucket_name"></a> [mimir\_blocks\_bucket\_name](#output\_mimir\_blocks\_bucket\_name) | S3 bucket name for Mimir blocks storage. |
| <a name="output_mimir_ruler_bucket_arn"></a> [mimir\_ruler\_bucket\_arn](#output\_mimir\_ruler\_bucket\_arn) | S3 ARN for Mimir ruler storage. |
| <a name="output_mimir_ruler_bucket_name"></a> [mimir\_ruler\_bucket\_name](#output\_mimir\_ruler\_bucket\_name) | S3 bucket name for Mimir ruler storage. |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_traces_bucket_arn"></a> [traces\_bucket\_arn](#output\_traces\_bucket\_arn) | S3 ARN for Tempo traces storage. |
| <a name="output_traces_bucket_name"></a> [traces\_bucket\_name](#output\_traces\_bucket\_name) | S3 bucket name for Tempo traces storage. |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Base64 encoded user data rendered for the provided inputs |

<!-- END_TF_DOCS -->