##### General configuration
account_num     = "514712703977"
account_num_r53 = "514712703977"
aws_region      = "us-west-2"
aws_role        = "CloudAdmin"
kms_role        = "CloudAdmin"
AppID           = "1001"
Environment     = "Dev" # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"      # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["sukx@pge.com", "oxdi@pge.com", "e6bo@pge.com"]
Owner              = ["sukx", "oxdi", "e6bo"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 # Order must be between 7 and 9 digits

##### General cluster configuration
cluster_name                  = "eks-node-test" # Theres 2 other places to update cluster name, do a find in this file for "#CLUSTER NAME"
hosted_zone                   = "nonprod.pge.com"
bootstrap_self_managed_addons = true
domain_env                    = "nonprod"
cluster_service_cidr          = "172.20.0.0/16"
ami_type                      = "AL2023_x86_64_STANDARD"
ami_id                        = "ami-002495de7d30f195d"
encrypt_ebs_csi               = true
k8s-version                   = "1.34"
argocd_git_auth               = "shared-argo-github-pat"         # Name of the secret in Secrets Manager for Argo CD to auth to pgetech/ccoe-managed-eks-addons
codebuild_git_auth            = "shared-codebuild-github-pat"    # Name of the secret in Secrets Manager for codebuild to auth to pgetech/ccoe-managed-eks-addons
custom_repo_url               = "https://github.com/pgetech/..." # Your GitHub repository URL for ArgoCD applications
custom_repo_branch            = ""


##### CCOE managed addons configuration - creates AWS resources that addons rely on ########
# If you are not using the addons, you can set these to false
# Once the addon resources are created, then you can commit your ArgoCD applications to your repo
create_efs_csi_resources            = false
create_eks_dashboard                = false
create_custom_role                  = false
create_ebs_csi_resources            = false
create_cloudwatch_agent             = false
create_vpc_cni_resources            = false
create_aws_for_fluentbit_resources  = false
create_cluster_autoscaler_resources = false
create_karpenter_resources          = false
create_loki_resources               = false
create_mimir_resources              = false
create_tempo_resources              = false

#
#
########################################################################################################
##### Advanced Configuration: You likely don't need to change these unless you know what you are doing #
########################################################################################################
#
#
parameter_vpc_id_name     = "/vpc/id"
parameter_subnet_id1_name = "/vpc/privatesubnet1/id"
parameter_subnet_id2_name = "/vpc/privatesubnet2/id"
parameter_subnet_id3_name = "/vpc/privatesubnet3/id"

# VPC CNI Addon Configuration
# This is the configuration for the VPC CNI addon, which allows for secondary CIDR support for pods.
# This is not required, but you probably should use it so you don't use up all your VPC IPs.
addon_configuration_values = {
  env = {
    "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG" = "true"
    "ENI_CONFIG_LABEL_DEF"               = "topology.kubernetes.io/zone"
    "ENABLE_PREFIX_DELEGATION"           = "true"
    "WARM_PREFIX_TARGET"                 = "1"
  }
}

# Useful when upgrading nodegroups to new k8s version
use_ami_latest = true
access_entries = {
  clusteradmins  = ["SecurityAdmin", "CloudAdmin"]
  clustereditors = []
  clusterviewers = [
    {
      role       = "SuperAdmin"
      namespaces = []
    }
  ]
}

# Uncomment if creating the cluster in non shared account, also this is diff for prod account
sns-topic = "arn:aws:sns:us-west-2:750713712981:eks-alarms-topic"

# Cluster dimensions
cluster_dimensions = {
  "cluster-node-cpu-utilization" = {
    metric_name         = "node_cpu_utilization",
    comparison_operator = "GreaterThanOrEqualToThreshold",
    period              = "60",
    statistic           = "Average"
    threshold           = "50",
  },
  "cluster-node-memory-utilization" = {
    metric_name         = "node_memory_utilization",
    comparison_operator = "GreaterThanOrEqualToThreshold",
    period              = "60",
    statistic           = "Average"
    threshold           = "50",
  },
}

namespace_dimensions = {}
# Service dimensions
service_dimensions = {
  "test-number-of-pods" = {
    metric_name         = "service_number_of_running_pods",
    comparison_operator = "LessThanOrEqualToThreshold",
    period              = "60",
    statistic           = "Average"
    threshold           = "0",
    namespace           = "default",
    service             = "ratings",
  },
}

# Pod dimensions
pod_dimensions = {
  "test-cpu-utilization" = {
    metric_name         = "pod_cpu_utilization_over_pod_limit",
    comparison_operator = "GreaterThanOrEqualToThreshold",
    period              = "60",
    statistic           = "Average"
    threshold           = "95",
    namespace           = "default",
    pod                 = "memconsumer",
  },
  "test-memory-utilization" = {
    metric_name         = "pod_memory_utilization_over_pod_limit",
    comparison_operator = "GreaterThanOrEqualToThreshold",
    period              = "60",
    statistic           = "Average"
    threshold           = "95",
    namespace           = "default",
    pod                 = "memconsumer",
  },
}

external_secrets_kms_key_arns    = []
cluster_autoscaler_cluster_names = ["e6bo-node-test"] #CLUSTER NAME

#custom role
custom_identity = "custom-role"
custom_identity_associations = {
  ex-one = {
    cluster_name    = "e6bo-node-test" #CLUSTER NAME
    namespace       = "custom"
    service_account = "custom"
  }
}
