<!-- BEGIN_TF_DOCS -->
# AWS eks cluster with  managed node group creation
This module will create eks and  managed groups.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
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
| <a name="module_aws-for-fluentbit-role"></a> [aws-for-fluentbit-role](#module\_aws-for-fluentbit-role) | ../internal/addons/roles | n/a |
| <a name="module_aws_efs_csi_pod_identity"></a> [aws\_efs\_csi\_pod\_identity](#module\_aws\_efs\_csi\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_aws_lb_controller_pod_identity"></a> [aws\_lb\_controller\_pod\_identity](#module\_aws\_lb\_controller\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_aws_vpc_cni_ipv4_pod_identity"></a> [aws\_vpc\_cni\_ipv4\_pod\_identity](#module\_aws\_vpc\_cni\_ipv4\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_cluster-autoscaler-role"></a> [cluster-autoscaler-role](#module\_cluster-autoscaler-role) | ../internal/addons/roles | n/a |
| <a name="module_custom_pod_identity"></a> [custom\_pod\_identity](#module\_custom\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_ebs-csi-pod-identity"></a> [ebs-csi-pod-identity](#module\_ebs-csi-pod-identity) | ../internal/addons/roles | n/a |
| <a name="module_eks_cloudwatch_dashboard_and_alerts"></a> [eks\_cloudwatch\_dashboard\_and\_alerts](#module\_eks\_cloudwatch\_dashboard\_and\_alerts) | ../internal/dashboard-alerts | n/a |
| <a name="module_external_dns_pod_identity"></a> [external\_dns\_pod\_identity](#module\_external\_dns\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_external_secrets_pod_identity"></a> [external\_secrets\_pod\_identity](#module\_external\_secrets\_pod\_identity) | ../internal/addons/roles | n/a |
| <a name="module_grafana_loki"></a> [grafana\_loki](#module\_grafana\_loki) | ../internal/addons/grafana-loki | n/a |
| <a name="module_grafana_mimir"></a> [grafana\_mimir](#module\_grafana\_mimir) | ../internal/addons/grafana-mimir | n/a |
| <a name="module_grafana_tempo"></a> [grafana\_tempo](#module\_grafana\_tempo) | ../internal/addons/grafana-tempo | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ../internal/addons/karpenter | n/a |
| <a name="module_validate-pge-tags"></a> [validate-pge-tags](#module\_validate-pge-tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_attach_aws_ebs_csi_policy"></a> [attach\_aws\_ebs\_csi\_policy](#input\_attach\_aws\_ebs\_csi\_policy) | Determines whether to attach the EBS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_efs_csi_policy"></a> [attach\_aws\_efs\_csi\_policy](#input\_attach\_aws\_efs\_csi\_policy) | Determines whether to attach the EFS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_for_fluentbit_policy"></a> [attach\_aws\_for\_fluentbit\_policy](#input\_attach\_aws\_for\_fluentbit\_policy) | Determines whether to attach the aws for fluentbit policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_lb_controller_targetgroup_binding_only_policy"></a> [attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy](#input\_attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy) | Determines whether to attach the AWS Load Balancer Controller policy for the TargetGroupBinding only | `bool` | `false` | no |
| <a name="input_attach_aws_vpc_cni_policy"></a> [attach\_aws\_vpc\_cni\_policy](#input\_attach\_aws\_vpc\_cni\_policy) | Determines whether to attach the VPC CNI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_external_dns_policy"></a> [attach\_external\_dns\_policy](#input\_attach\_external\_dns\_policy) | Determines whether to attach the External DNS IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_external_secrets_policy"></a> [attach\_external\_secrets\_policy](#input\_attach\_external\_secrets\_policy) | Determines whether to attach the External Secrets policy to the role | `bool` | `false` | no |
| <a name="input_aws_ebs_csi_kms_arns"></a> [aws\_ebs\_csi\_kms\_arns](#input\_aws\_ebs\_csi\_kms\_arns) | KMS key ARNs to allow EBS CSI to manage encrypted volumes | `list(string)` | `[]` | no |
| <a name="input_aws_ebs_csi_policy_name"></a> [aws\_ebs\_csi\_policy\_name](#input\_aws\_ebs\_csi\_policy\_name) | Custom name of the EBS CSI IAM policy | `string` | `null` | no |
| <a name="input_aws_efs_csi_policy_name"></a> [aws\_efs\_csi\_policy\_name](#input\_aws\_efs\_csi\_policy\_name) | Custom name of the EFS CSI IAM policy | `string` | `null` | no |
| <a name="input_aws_lb_controller_policy_name"></a> [aws\_lb\_controller\_policy\_name](#input\_aws\_lb\_controller\_policy\_name) | Custom name of the AWS Load Balancer Controller IAM policy | `string` | `null` | no |
| <a name="input_aws_lb_controller_targetgroup_arns"></a> [aws\_lb\_controller\_targetgroup\_arns](#input\_aws\_lb\_controller\_targetgroup\_arns) | List of Target groups ARNs using Load Balancer Controller | `list(string)` | `[]` | no |
| <a name="input_aws_lb_controller_targetgroup_only_policy_name"></a> [aws\_lb\_controller\_targetgroup\_only\_policy\_name](#input\_aws\_lb\_controller\_targetgroup\_only\_policy\_name) | Custom name of the AWS Load Balancer Controller IAM policy for the TargetGroupBinding only | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_vpc_cni_enable_ipv4"></a> [aws\_vpc\_cni\_enable\_ipv4](#input\_aws\_vpc\_cni\_enable\_ipv4) | Determines whether to enable IPv4 permissions for VPC CNI policy | `bool` | `false` | no |
| <a name="input_aws_vpc_cni_policy_name"></a> [aws\_vpc\_cni\_policy\_name](#input\_aws\_vpc\_cni\_policy\_name) | Custom name of the VPC CNI IAM policy | `string` | `null` | no |
| <a name="input_cluster_autoscaler_cluster_names"></a> [cluster\_autoscaler\_cluster\_names](#input\_cluster\_autoscaler\_cluster\_names) | List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy | `list(string)` | `[]` | no |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster | `string` | `""` | no |
| <a name="input_cluster_dimensions"></a> [cluster\_dimensions](#input\_cluster\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>comparison\_operator is the type of comparison operation. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>Specify an empty map if you do not want to notify Cluster level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of your EKS Cluster | `string` | n/a | yes |
| <a name="input_create_aws_for_fluentbit_resources"></a> [create\_aws\_for\_fluentbit\_resources](#input\_create\_aws\_for\_fluentbit\_resources) | Determines whether to create aws for fluentbit IAM Role | `bool` | `false` | no |
| <a name="input_create_cluster_autoscaler_resources"></a> [create\_cluster\_autoscaler\_resources](#input\_create\_cluster\_autoscaler\_resources) | Determines whether to create the Cluster Autoscaler IAM role | `bool` | `false` | no |
| <a name="input_create_custom_role"></a> [create\_custom\_role](#input\_create\_custom\_role) | Determines whether to create the custom IAM role | `bool` | `false` | no |
| <a name="input_create_ebs_csi_resources"></a> [create\_ebs\_csi\_resources](#input\_create\_ebs\_csi\_resources) | Determines whether to create the ebs csi IAM role | `bool` | `false` | no |
| <a name="input_create_efs_csi_resources"></a> [create\_efs\_csi\_resources](#input\_create\_efs\_csi\_resources) | Determines whether to create the efs csi IAM role | `bool` | `false` | no |
| <a name="input_create_eks_dashboard"></a> [create\_eks\_dashboard](#input\_create\_eks\_dashboard) | eks dashboard true/false | `bool` | `false` | no |
| <a name="input_create_external_dns_resources"></a> [create\_external\_dns\_resources](#input\_create\_external\_dns\_resources) | Determines whether to create the external dns IAM role | `bool` | `true` | no |
| <a name="input_create_external_secrets_resources"></a> [create\_external\_secrets\_resources](#input\_create\_external\_secrets\_resources) | Determines whether to create the external secrets IAM role | `bool` | `true` | no |
| <a name="input_create_karpenter_resources"></a> [create\_karpenter\_resources](#input\_create\_karpenter\_resources) | Create karpenter adddon resources, node role , controller role, queue for eks cluster | `bool` | `false` | no |
| <a name="input_create_lb_controller_resources"></a> [create\_lb\_controller\_resources](#input\_create\_lb\_controller\_resources) | Determines whether to create the AWS Load Balancer Controller IAM role | `bool` | `true` | no |
| <a name="input_create_loki_resources"></a> [create\_loki\_resources](#input\_create\_loki\_resources) | Determines whether to create Grafana Loki resources such as S3 buckets and IAM roles | `bool` | `false` | no |
| <a name="input_create_mimir_resources"></a> [create\_mimir\_resources](#input\_create\_mimir\_resources) | Determines whether to create Grafana Mimir resources such as S3 buckets and IAM roles | `bool` | `false` | no |
| <a name="input_create_tempo_resources"></a> [create\_tempo\_resources](#input\_create\_tempo\_resources) | Determines whether to create Grafana Tempo resources such as S3 buckets and IAM roles | `bool` | `false` | no |
| <a name="input_create_vpc_cni_resources"></a> [create\_vpc\_cni\_resources](#input\_create\_vpc\_cni\_resources) | Determines whether to create VPC CNI IAM Role | `bool` | `false` | no |
| <a name="input_custom_identity"></a> [custom\_identity](#input\_custom\_identity) | Name of IAM role | `string` | `""` | no |
| <a name="input_custom_identity_additional_policy_arns"></a> [custom\_identity\_additional\_policy\_arns](#input\_custom\_identity\_additional\_policy\_arns) | ARNs of additional policies to attach to the IAM role | `map(string)` | `{}` | no |
| <a name="input_custom_identity_associations"></a> [custom\_identity\_associations](#input\_custom\_identity\_associations) | Map of Pod Identity associations to be created (map of maps) | `any` | `{}` | no |
| <a name="input_custom_identity_override_policy_documents"></a> [custom\_identity\_override\_policy\_documents](#input\_custom\_identity\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_source_policy_documents"></a> [custom\_identity\_source\_policy\_documents](#input\_custom\_identity\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document | `list(string)` | `[]` | no |
| <a name="input_custom_identity_trust_policy_conditions"></a> [custom\_identity\_trust\_policy\_conditions](#input\_custom\_identity\_trust\_policy\_conditions) | A list of conditions to add to the role trust policy | `any` | `[]` | no |
| <a name="input_custom_image_registry_uri"></a> [custom\_image\_registry\_uri](#input\_custom\_image\_registry\_uri) | Custom image registry URI map of `{region = dkr.endpoint }` | `map(string)` | `{}` | no |
| <a name="input_domain_env"></a> [domain\_env](#input\_domain\_env) | [NONPROD/PROD]Environment value to pick respective Domain name of the Route53 hosted zone to use with External DNS. | `string` | `"nonprod"` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Endpoint for your Kubernetes API server | `string` | `""` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | The Kubernetes version for the cluster | `string` | `null` | no |
| <a name="input_enable_aws_cloudwatch_metrics"></a> [enable\_aws\_cloudwatch\_metrics](#input\_enable\_aws\_cloudwatch\_metrics) | Enable AWS CloudWatch Metrics add-on for Container Insights | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Load Balancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_kube_state_metrics"></a> [enable\_kube\_state\_metrics](#input\_enable\_kube\_state\_metrics) | Enable kube state metrics add-on | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `false` | no |
| <a name="input_encrypt_ebs_csi"></a> [encrypt\_ebs\_csi](#input\_encrypt\_ebs\_csi) | Determines whether to encrypt EBS volumes created by the EBS CSI driver | `bool` | `false` | no |
| <a name="input_external_dns_policy_name"></a> [external\_dns\_policy\_name](#input\_external\_dns\_policy\_name) | Custom name of the External DNS IAM policy | `string` | `null` | no |
| <a name="input_external_secrets_create_permission"></a> [external\_secrets\_create\_permission](#input\_external\_secrets\_create\_permission) | Determines whether External Secrets has permission to create/delete secrets | `bool` | `false` | no |
| <a name="input_external_secrets_kms_key_arns"></a> [external\_secrets\_kms\_key\_arns](#input\_external\_secrets\_kms\_key\_arns) | List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_policy_name"></a> [external\_secrets\_policy\_name](#input\_external\_secrets\_policy\_name) | Custom name of the External Secrets IAM policy | `string` | `null` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_namespace_dimensions"></a> [namespace\_dimensions](#input\_namespace\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the namespace name to be notified. <br>Specify an empty map if you do not want to notify Namespace level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_pod_dimensions"></a> [pod\_dimensions](#input\_pod\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the pod to be notified runs. <br>Pod is the pod name to be notified. <br>Specify an empty map if you do not want to perform Pod-level alert notifications. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>    pod                 = string<br/>  }))</pre> | `{}` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the SQS queue | `string` | `null` | no |
| <a name="input_route53_zone_arns"></a> [route53\_zone\_arns](#input\_route53\_zone\_arns) | List of Route53 zones ARNs which external-dns will have access to create/manage records | `list(string)` | `[]` | no |
| <a name="input_service_dimensions"></a> [service\_dimensions](#input\_service\_dimensions) | List of metrics to notify. <br>metric\_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the notification target Service operates. <br>Service is the Pod name to be notified. <br>Specify an empty map if you do not want to notify Service level alerts. | <pre>map(object({<br/>    metric_name         = string<br/>    comparison_operator = string<br/>    period              = string<br/>    statistic           = string<br/>    threshold           = string<br/>    namespace           = string<br/>    service             = string<br/>  }))</pre> | `{}` | no |
| <a name="input_sns-topic"></a> [sns-topic](#input\_sns-topic) | input email for alarm notification | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_efs_csi_pod_identity_role"></a> [aws\_efs\_csi\_pod\_identity\_role](#output\_aws\_efs\_csi\_pod\_identity\_role) | ADDON ROLES --- aws\_efs\_csi\_pod\_identity role |
| <a name="output_aws_lb_controller_pod_identity_role"></a> [aws\_lb\_controller\_pod\_identity\_role](#output\_aws\_lb\_controller\_pod\_identity\_role) | ADDON ROLES --- aws\_lb\_controller\_pod\_identity role |
| <a name="output_cluster-autoscaler-role"></a> [cluster-autoscaler-role](#output\_cluster-autoscaler-role) | ADDON ROLES --- cluster-autoscaler-role |
| <a name="output_custom_pod_identity_role"></a> [custom\_pod\_identity\_role](#output\_custom\_pod\_identity\_role) | ADDON ROLES --- custom\_pod\_identity role |
| <a name="output_ebs-csi-pod-identity_role"></a> [ebs-csi-pod-identity\_role](#output\_ebs-csi-pod-identity\_role) | ADDON ROLES --- ebs-csi-pod-identity role |
| <a name="output_ebs_csi_kms_key_arn"></a> [ebs\_csi\_kms\_key\_arn](#output\_ebs\_csi\_kms\_key\_arn) | ARN of the KMS key for EBS CSI driver to encrypt EBS volumes it creates |
| <a name="output_eks-cloudwatch-dashboard-arn"></a> [eks-cloudwatch-dashboard-arn](#output\_eks-cloudwatch-dashboard-arn) | n/a |
| <a name="output_external_secrets_pod_identity_role"></a> [external\_secrets\_pod\_identity\_role](#output\_external\_secrets\_pod\_identity\_role) | ADDON ROLES --- external\_secrets\_pod\_identity role |
| <a name="output_loki_chunks_bucket_arn"></a> [loki\_chunks\_bucket\_arn](#output\_loki\_chunks\_bucket\_arn) | Grafana Loki s3 ARN for chunks |
| <a name="output_loki_chunks_bucket_name"></a> [loki\_chunks\_bucket\_name](#output\_loki\_chunks\_bucket\_name) | Grafana Loki s3 bucket name for chunks |
| <a name="output_loki_ruler_bucket_arn"></a> [loki\_ruler\_bucket\_arn](#output\_loki\_ruler\_bucket\_arn) | Grafana Loki s3 ARN for ruler |
| <a name="output_loki_ruler_bucket_name"></a> [loki\_ruler\_bucket\_name](#output\_loki\_ruler\_bucket\_name) | Grafana Loki s3 bucket name for ruler |
| <a name="output_mimir_blocks_bucket_arn"></a> [mimir\_blocks\_bucket\_arn](#output\_mimir\_blocks\_bucket\_arn) | S3 ARN for Mimir blocks storage. |
| <a name="output_mimir_blocks_bucket_name"></a> [mimir\_blocks\_bucket\_name](#output\_mimir\_blocks\_bucket\_name) | S3 bucket name for Mimir blocks storage. |
| <a name="output_mimir_ruler_bucket_arn"></a> [mimir\_ruler\_bucket\_arn](#output\_mimir\_ruler\_bucket\_arn) | S3 ARN for Mimir ruler storage. |
| <a name="output_mimir_ruler_bucket_name"></a> [mimir\_ruler\_bucket\_name](#output\_mimir\_ruler\_bucket\_name) | S3 bucket name for Mimir ruler storage. |
| <a name="output_tempo_traces_bucket_arn"></a> [tempo\_traces\_bucket\_arn](#output\_tempo\_traces\_bucket\_arn) | S3 ARN for Tempo traces storage. |
| <a name="output_tempo_traces_bucket_name"></a> [tempo\_traces\_bucket\_name](#output\_tempo\_traces\_bucket\_name) | S3 bucket name for Tempo traces storage. |

<!-- END_TF_DOCS -->