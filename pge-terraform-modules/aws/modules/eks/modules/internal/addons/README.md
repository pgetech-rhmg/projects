<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

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
| <a name="module_aws_efs_csi_pod_identity"></a> [aws\_efs\_csi\_pod\_identity](#module\_aws\_efs\_csi\_pod\_identity) | ./all-addon-roles | n/a |
| <a name="module_aws_lb_controller_pod_identity"></a> [aws\_lb\_controller\_pod\_identity](#module\_aws\_lb\_controller\_pod\_identity) | ./all-addon-roles | n/a |
| <a name="module_aws_lb_controller_targetgroup_binding_only_pod_identity"></a> [aws\_lb\_controller\_targetgroup\_binding\_only\_pod\_identity](#module\_aws\_lb\_controller\_targetgroup\_binding\_only\_pod\_identity) | ./all-addon-roles | n/a |
| <a name="module_aws_vpc_cni_ipv4_pod_identity"></a> [aws\_vpc\_cni\_ipv4\_pod\_identity](#module\_aws\_vpc\_cni\_ipv4\_pod\_identity) | ./all-addon-roles | n/a |
| <a name="module_cluster-autoscaler-role"></a> [cluster-autoscaler-role](#module\_cluster-autoscaler-role) | ./all-addon-roles | n/a |
| <a name="module_ebs-csi-pod-identity"></a> [ebs-csi-pod-identity](#module\_ebs-csi-pod-identity) | ./all-addon-roles | n/a |
| <a name="module_external_secrets_pod_identity"></a> [external\_secrets\_pod\_identity](#module\_external\_secrets\_pod\_identity) | ./all-addon-roles | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_aws_ebs_csi_policy"></a> [attach\_aws\_ebs\_csi\_policy](#input\_attach\_aws\_ebs\_csi\_policy) | Determines whether to attach the EBS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_efs_csi_policy"></a> [attach\_aws\_efs\_csi\_policy](#input\_attach\_aws\_efs\_csi\_policy) | Determines whether to attach the EFS CSI IAM policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_lb_controller_policy"></a> [attach\_aws\_lb\_controller\_policy](#input\_attach\_aws\_lb\_controller\_policy) | Determines whether to attach the AWS Load Balancer Controller policy to the role | `bool` | `false` | no |
| <a name="input_attach_aws_lb_controller_targetgroup_binding_only_policy"></a> [attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy](#input\_attach\_aws\_lb\_controller\_targetgroup\_binding\_only\_policy) | Determines whether to attach the AWS Load Balancer Controller policy for the TargetGroupBinding only | `bool` | `false` | no |
| <a name="input_attach_aws_vpc_cni_policy"></a> [attach\_aws\_vpc\_cni\_policy](#input\_attach\_aws\_vpc\_cni\_policy) | Determines whether to attach the VPC CNI IAM policy to the role | `bool` | `false` | no |
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
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of your EKS Cluster | `string` | n/a | yes |
| <a name="input_create_cluster_autoscaler_role"></a> [create\_cluster\_autoscaler\_role](#input\_create\_cluster\_autoscaler\_role) | Determines whether to create the Cluster Autoscaler IAM role | `bool` | `false` | no |
| <a name="input_create_ebs_csi"></a> [create\_ebs\_csi](#input\_create\_ebs\_csi) | Determines whether to create the ebs csi IAM role | `bool` | `false` | no |
| <a name="input_create_efs_csi"></a> [create\_efs\_csi](#input\_create\_efs\_csi) | Determines whether to create the efs csi IAM role | `bool` | `false` | no |
| <a name="input_create_external_dns"></a> [create\_external\_dns](#input\_create\_external\_dns) | Determines whether to create the external dns IAM role | `bool` | `false` | no |
| <a name="input_create_external_secrets"></a> [create\_external\_secrets](#input\_create\_external\_secrets) | Determines whether to create the external secrets IAM role | `bool` | `false` | no |
| <a name="input_create_lb_controller"></a> [create\_lb\_controller](#input\_create\_lb\_controller) | Determines whether to create the lb controller IAM Role | `bool` | `false` | no |
| <a name="input_create_vpc_cni"></a> [create\_vpc\_cni](#input\_create\_vpc\_cni) | Determines whether to create VPC CNI IAM Role | `bool` | `false` | no |
| <a name="input_external_secrets_create_permission"></a> [external\_secrets\_create\_permission](#input\_external\_secrets\_create\_permission) | Determines whether External Secrets has permission to create/delete secrets | `bool` | `false` | no |
| <a name="input_external_secrets_kms_key_arns"></a> [external\_secrets\_kms\_key\_arns](#input\_external\_secrets\_kms\_key\_arns) | List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_policy_name"></a> [external\_secrets\_policy\_name](#input\_external\_secrets\_policy\_name) | Custom name of the External Secrets IAM policy | `string` | `null` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->