# EKS Cluster Variables Configuration
variable "cluster_name" {
  type        = string
  description = "The name of your EKS Cluster"
  validation {
    condition     = 20 >= length(var.cluster_name) && length(var.cluster_name) > 0 && can(regex("^[0-9A-Za-z][A-Za-z0-9-_]+$", var.cluster_name))
    error_message = "'cluster_name' should be between 1 and 20 characters, start with alphanumeric character and contain alphanumeric characters, dashes and underscores."
  }
}

variable "k8s-version" {
  type        = string
  description = "Required K8s version"
  validation {
    condition     = can(regex("^[0-9].[0-9][0-9]+$", var.k8s-version))
    error_message = "k8s-version to be among 1.22, 1.23."
  }
}

variable "role_service" {
  type        = list(string)
  default     = ["eks.amazonaws.com"]
  description = "Aws service of the iam role"
}


variable "role_service_managed" {
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
  description = "Aws service of the iam role"
}

################################################################################
# Access Entry
################################################################################
variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type = object({
    clusteradmins = list(string)
    clustereditors = list(object({
      role       = string
      namespaces = list(string)
    }))
    clusterviewers = list(object({
      role       = string
      namespaces = list(string)
    }))
  })
}

################################################################################
# EKS Addons
################################################################################
variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "cluster_addons_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster addons"
  type        = map(string)
  default     = {}
}

variable "addon_configuration_values" {
  description = "Configuration values for the EKS addon"
  type        = map(any)
  default     = {}
}

variable "create_cluster_autoscaler_resources" {
  description = "Determines whether to attach the Cluster Autoscaler IAM policy to the role"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_cluster_names" {
  description = "List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy"
  type        = list(string)
  default     = []
}

variable "external_secrets_kms_key_arns" {
  description = "List of secrets kms key arns"
  type        = list(string)
  default     = []
}

variable "create_efs_csi_resources" {
  description = "Determines whether to create the efs csi IAM role"
  type        = bool
  default     = false
}

#vpc cni
variable "create_vpc_cni_resources" {
  description = "Determines whether to create VPC CNI IAM Role"
  type        = bool
  default     = false
}
variable "attach_aws_vpc_cni_policy" {
  description = "Determines whether to attach the VPC CNI IAM policy to the role"
  type        = bool
  default     = false
}

variable "aws_vpc_cni_policy_name" {
  description = "Custom name of the VPC CNI IAM policy"
  type        = string
  default     = null
}

variable "aws_vpc_cni_enable_ipv4" {
  description = "Determines whether to enable IPv4 permissions for VPC CNI policy"
  type        = bool
  default     = false
}

################################################################################
# EKS Pod Identity
################################################################################
variable "association_defaults" {
  description = "Default values used across all Pod Identity associations created unless a more specific value is provided"
  type        = map(string)
  default     = {}
}

variable "associations" {
  description = "Map of Pod Identity associations to be created (map of maps)"
  type        = any
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}

### eks new variables ########
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

### addons variables ##########
variable "kube_proxy" {
  type        = string
  description = "kube proxy name"
  default     = "kube-proxy"
}

# Variables for aws_ssm_parameter
variable "parameter_vpc_id_name" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id1_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id3_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "domain_env" {
  description = "Enable external dns add-on"
  type        = string
  default     = "nonprod"
}

variable "use_ami_latest" {
  description = "Set this parameter to true during upgrade to create parallel nodegroups with latest version"
  type        = bool
  default     = false
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"

}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
  default     = "eks-test"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key"
  type        = string
}

variable "user" {
  description = "User id for aws session"
  type        = string
  default     = "rh1b"
}

#-----------AWS CloudWatch Metrics-------------
variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS CloudWatch Metrics add-on for Container Insights"
  type        = bool
  default     = false
}

variable "cluster_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>comparison_operator is the type of comparison operation. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>Specify an empty map if you do not want to notify Cluster level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
  }))
  default = {}
}

variable "namespace_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the namespace name to be notified. <br>Specify an empty map if you do not want to notify Namespace level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
  }))
  default = {}
}

variable "service_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the notification target Service operates. <br>Service is the Pod name to be notified. <br>Specify an empty map if you do not want to notify Service level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
    service             = string
  }))
  default = {}
}

variable "pod_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the pod to be notified runs. <br>Pod is the pod name to be notified. <br>Specify an empty map if you do not want to perform Pod-level alert notifications."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
    pod                 = string
  }))
  default = {}
}

variable "create_eks_dashboard" {
  description = "eks dashboard true/false"
  type        = bool
}

variable "sns-topic" {
  description = "input email for alarm notification"
  type        = string
  default     = ""
}

#--------custom-role--------------------
variable "custom_identity" {
  description = "Name of IAM role"
  type        = string
  default     = ""
}

variable "custom_identity_associations" {
  description = "Map of Pod Identity associations to be created (map of maps)"
  type        = any
  default     = {}
}

variable "custom_identity_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "custom_identity_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "custom_identity_additional_policy_arns" {
  description = "ARNs of additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "custom_identity_trust_policy_conditions" {
  description = "A list of conditions to add to the role trust policy"
  type        = any
  default     = []
}
variable "create_karpenter_resources" {
  description = "Create karpenter adddon resources, node role , controller role, queue for eks cluster"
  type        = bool
  default     = false
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}
variable "create_ebs_csi_resources" {
  description = "Determines whether to create the ebs csi IAM role"
  type        = bool
  default     = false
}

variable "create_custom_role" {
  description = "Determines whether to create the custom IAM role"
  type        = bool
  default     = false
}

variable "create_cloudwatch_agent" {
  description = "Create cloudwatch agent for eks cluster"
  type        = bool
}

variable "environment_variables_codebuild_stage" {
  description = "Provide the list of optional environment variables required for codebuild stage"
  type        = list(any)
  default     = []
}


variable "environment_image_codebuild" {
  description = "Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "encryption_key_id" {
  description = "Enter the KMS key arn for encryption - uses for both codepipeline and codebuild"
  type        = string
  default     = null
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "create_aws_for_fluentbit_resources" {
  description = "Determines whether to create aws for fluentbit IAM Role"
  type        = bool
  default     = false
}

variable "hosted_zone" {
  description = "Route53 hosted zone name"
  type        = string
}
variable "account_num_r53" {
  description = "Route53 account number"
  type        = string
  default     = "514712703977"
}

variable "bootstrap_self_managed_addons" {
  description = "Bootstrap the CCOE managed addons, set to false if you are not using them"
  type        = bool
  default     = true
}

variable "aws_r53_role" {
  description = "AWS role to assume for Route53 operations"
  type        = string
  default     = "CloudAdmin"
}

variable "codebuild_git_auth" {
  description = "ARN of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the EKS bootstrap repository"
  type        = string
}

variable "argocd_git_auth" {
  description = "Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the ArgoCD repository"
  type        = string
}

variable "custom_repo_url" {
  description = "Custom repository URL for the bootstrap process"
  type        = string
}

variable "custom_repo_branch" {
  description = "name of the branch to be used for your own Argo CD repository"
  type        = string
  default     = "main"
}

variable "create_loki_resources" {
  description = "Create loki resources for eks cluster"
  type        = bool
  default     = false
}

variable "create_mimir_resources" {
  description = "Create mimir resources for eks cluster"
  type        = bool
  default     = false
}

variable "create_tempo_resources" {
  description = "Create tempo resources for eks cluster"
  type        = bool
  default     = false
}

variable "encrypt_ebs_csi" {
  description = "Determines whether to encrypt EBS volumes created by the EBS CSI driver"
  type        = bool
  default     = false
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = ""
  nullable    = false
}

variable "ami_id" {
  description = "Custom AMI ID to use for the EKS Node Group"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_service_cidr" {
  description = "The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself"
  type        = string
  default     = ""
  nullable    = false
}
