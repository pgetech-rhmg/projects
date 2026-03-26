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
    condition     = can(regex("^[0-9].[3-9][3-9]+$", var.k8s-version))
    error_message = "k8s-version to be among 1.33, 1.34."
  }
}

variable "role_service" {
  type        = list(string)
  default     = ["eks.amazonaws.com"]
  description = "Aws service of the iam role"
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "role_service_managed" {
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
  description = "Aws service of the iam role"
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

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"

}

variable "bootstrap_self_managed_addons" {
  description = "Indicates whether or not to bootstrap self-managed addons after the cluster has been created"
  type        = bool
  default     = true
}

variable "cluster_compute_config" {
  description = "Configuration block for the cluster compute configuration"
  type        = any
  default     = {}
}

variable "cluster_upgrade_policy" {
  description = "Configuration block for the cluster upgrade policy"
  type        = any
  default     = {}
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "attach_cluster_encryption_policy" {
  description = "Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided"
  type        = bool
  default     = true
}

### eks new variables ########
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}
variable "cluster_update_timeout" {
  description = "Timeout value when updating the EKS cluster."
  type        = string
  default     = "60m"
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}


variable "tags" {
  description = "(optional) Tags to assign to the cluster"
  type        = map(string)
}
variable "create" {
  description = "Use to toggle creation of sources by this module"
  type        = bool
  default     = true
}

variable "addon_version" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
  default     = null
}

### addons variables ##########

variable "aws_ebs_csi_driver" {
  type        = string
  description = "aws ebs csi driver name"
  default     = "aws-ebs-csi-driver"
}

# Variables for aws_ssm_parameter

variable "parameter_vpc_id_name" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
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
  default     = ""
}

variable "network_interfaces" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(any)
  default     = []
}


variable "aws_kms_key_arn" {
  description = "KMS encryption key ARN for the EKS cluster. If not provided, a new KMS key will be created automatically (requires kms_role to be specified)"
  type        = string
  default     = null
  validation {
    condition     = var.aws_kms_key_arn == null || can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.aws_kms_key_arn))
    error_message = "KMS ARN must be in the format: arn:aws:kms:us-west-2:12345678912:key/e41b54e1-23ca-4906-8ca0-417f10463731"
  }
}


variable "resources" {
  description = "(Required) List of strings with resources to be encrypted."
  type        = list(string)
  default     = ["secrets"]
}

################################################################################
# Access Entry
################################################################################

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

################################################################################
# EKS Managed Node Group
################################################################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}

variable "use_ami_latest" {
  description = "Set this parameter to true during upgrade to create parallel nodegroups with latest version"
  type        = bool
  default     = false

}


################################################################################
# Launch template
################################################################################

variable "create_launch_template" {
  description = "Determines whether to create a launch template or not. If set to `false`, EKS will use its own default launch template"
  type        = bool
  default     = true
}


variable "launch_template_id" {
  description = "The ID of an existing launch template to use. Required when `create_launch_template` = `false` and `use_custom_launch_template` = `true`"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of launch template to be created"
  type        = string
  default     = null
}

variable "launch_template_use_name_prefix" {
  description = "Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix"
  type        = bool
  default     = true
}

variable "launch_template_description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "launch_template_default_version" {
  description = "Default version of the launch template"
  type        = string
  default     = null
}

variable "update_launch_template_default_version" {
  description = "Whether to update the launch templates default version on each update. Conflicts with `launch_template_default_version`"
  type        = bool
  default     = true
}


variable "kernel_id" {
  description = "The kernel ID"
  type        = string
  default     = null
}

################################################################################
# EKS Managed Node Group
################################################################################


variable "name" {
  description = "Name of the EKS managed node group"
  type        = string
  default     = ""
}


variable "launch_template_version" {
  description = "Launch template version number. The default is `$Default`"
  type        = string
  default     = null
}


variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the node group"
  type        = map(string)
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}


variable "cpu_options" {
  description = "The CPU options for the instance"
  type        = map(string)
  default     = {}
}


variable "create_cloudwatch_agent" {
  description = "Create cloudwatch agent for eks cluster"
  type        = bool
  default     = false
}

#metrics server
variable "create_metrics_server" {
  description = "Create metrics server adddon for eks cluster"
  type        = bool
  default     = true
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

variable "acm_certificate_id" {
  description = "The ARN of the ACM certificate to use for the load balancer"
  type        = string
  default     = ""
}

variable "hosted_zone" {
  description = "The hosted zone ID of the domain"
  type        = string
}

variable "account_num_r53" {
  description = "Route53 account number"
  type        = string
  default     = "514712703977" #nonprod
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
  default     = "eks-test"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key. Required when aws_kms_key_arn is not provided (i.e., when a new KMS key will be created)"
  type        = string
  default     = null
  validation {
    condition     = var.aws_kms_key_arn != null || var.kms_role != null
    error_message = "kms_role is required when aws_kms_key_arn is not provided."
  }
}

variable "aws_r53_role" {
  description = "AWS role to assume for Route53"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}

variable "codebuild_git_auth" {
  description = "Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the EKS bootstrap repository"
  type        = string
}

variable "argocd_git_auth" {
  description = "Name of the GitHub Personal Access Token secret in Secrets Manager used for authentication with the ArgoCD repository"
  type        = string
}

variable "custom_repo_url" {
  description = "Custom repository URL for the bootstrap process"
  type        = string
  validation {
    condition     = var.custom_repo_url == null || var.custom_repo_url != "https://github.com/pgetech/..."
    error_message = "custom_repo_url cannot be set to the placeholder value 'https://github.com/pgetech/...'. Please provide a valid GitHub repository URL."
  }
}

variable "custom_repo_branch" {
  description = "Custom repository branch for the bootstrap process"
  type        = string
  validation {
    condition     = var.custom_repo_branch == null || var.custom_repo_branch != ""
    error_message = "custom_repo_branch cannot be an empty string. Please provide a valid branch name."
  }
}

variable "create_auto_iam_role" {
  description = "Determines whether an IAM role is created for the cluster"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_auto_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "prefix_separator" {
  description = "The separator to use between the prefix and the generated timestamp for resource names"
  type        = string
  default     = "-"
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "The IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

# TODO - will be removed in next breaking change; user can add the policy on their own when needed
variable "enable_security_groups_for_pods" {
  description = "Determines whether to add the necessary IAM permission policy for security groups for pods"
  type        = bool
  default     = true
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "cluster_encryption_policy_use_name_prefix" {
  description = "Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "cluster_encryption_policy_name" {
  description = "Name to use on cluster encryption policy created"
  type        = string
  default     = null
}

variable "cluster_encryption_policy_description" {
  description = "Description of the cluster encryption policy created"
  type        = string
  default     = "Cluster encryption policy to allow cluster role to utilize CMK provided"
}

variable "cluster_encryption_policy_path" {
  description = "Cluster encryption policy path"
  type        = string
  default     = null
}

variable "cluster_encryption_policy_tags" {
  description = "A map of additional tags to add to the cluster encryption policy created"
  type        = map(string)
  default     = {}
}

variable "dataplane_wait_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed node group(s), self-managed node group(s), Fargate profile(s))"
  type        = string
  default     = "30s"
}

variable "enable_auto_mode_custom_tags" {
  description = "Determines whether to enable permissions for custom tags resources created by EKS Auto Mode"
  type        = bool
  default     = true
}

################################################################################
# EKS Auto Node IAM Role
################################################################################

variable "create_auto_node_iam_role" {
  description = "Determines whether an EKS Auto node IAM role is created"
  type        = bool
  default     = true
}

variable "auto_node_iam_role_name" {
  description = "Name to use on the EKS Auto node IAM role created"
  type        = string
  default     = null
}

variable "auto_node_iam_role_use_name_prefix" {
  description = "Determines whether the EKS Auto node IAM role name (`auto_node_iam_role_use_name_prefix`) is used as a prefix"
  type        = bool
  default     = true
}

variable "auto_node_iam_role_path" {
  description = "The EKS Auto node IAM role path"
  type        = string
  default     = null
}

variable "auto_node_iam_role_description" {
  description = "Description of the EKS Auto node IAM role"
  type        = string
  default     = null
}

variable "auto_node_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role"
  type        = string
  default     = null
}

variable "auto_node_iam_role_additional_policies" {
  description = "Additional policies to be added to the EKS Auto node IAM role"
  type        = map(string)
  default     = {}
}

variable "auto_node_iam_role_tags" {
  description = "A map of additional tags to add to the EKS Auto node IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# User Data
################################################################################

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = ""
  nullable    = false
}

variable "platform" {
  description = "Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based"
  type        = string
  default     = "linux"
}

variable "user_data_template_path" {
  description = "Path to a local, custom user data template file to use when rendering user data"
  type        = string
  default     = ""
  nullable    = false
}

variable "enable_bootstrap_user_data" {
  description = "Determines whether the bootstrap configurations are populated within the user data template. Only valid when using a custom AMI via `ami_id`"
  type        = bool
  default     = false
  nullable    = false
}

variable "cluster_endpoint" {
  description = "Endpoint of associated EKS cluster"
  type        = string
  default     = null
}

variable "cluster_auth_base64" {
  description = "Base64 encoded CA of associated EKS cluster"
  type        = string
  default     = null
}

variable "cluster_service_cidr" {
  description = "The CIDR block (IPv4 or IPv6) used by the cluster to assign Kubernetes service IP addresses. This is derived from the cluster itself"
  type        = string
  default     = null
}

variable "pre_bootstrap_user_data" {
  description = "User data that is injected into the user data script ahead of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = null
}

variable "post_bootstrap_user_data" {
  description = "User data that is appended to the user data script after of the EKS bootstrap script. Not used when `ami_type` = `BOTTLEROCKET_*`"
  type        = string
  default     = null
}

variable "bootstrap_extra_args" {
  description = "Additional arguments passed to the bootstrap script. When `ami_type` = `BOTTLEROCKET_*`; these are additional [settings](https://github.com/bottlerocket-os/bottlerocket#settings) that are provided to the Bottlerocket user data"
  type        = string
  default     = null
}

variable "cloudinit_pre_nodeadm" {
  description = "Array of cloud-init document parts that are created before the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default = null
}

variable "cloudinit_post_nodeadm" {
  description = "Array of cloud-init document parts that are created after the nodeadm document part"
  type = list(object({
    content      = string
    content_type = optional(string)
    filename     = optional(string)
    merge_type   = optional(string)
  }))
  default = null
}

variable "selected_nodegroup" {
  description = "The key of the node group in eks_managed_node_groups to use for launch template settings. E.g., 'launch_template_nodegroup' or 'launch_template_nodegroup_multi'"
  type        = string
  default     = "launch_template_nodegroup"
}