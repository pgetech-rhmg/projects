variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Role Trust Policy
################################################################################

variable "trust_policy_conditions" {
  description = "A list of conditions to add to the role trust policy"
  type        = any
  default     = []
}

variable "trust_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for the role trust policy"
  type        = any
  default     = []
}

################################################################################
# IAM Role
################################################################################

variable "name" {
  description = "Name of IAM role"
  type        = string
  default     = ""
}

variable "use_name_prefix" {
  description = "Determines whether the role name and policy name(s) are used as a prefix"
  type        = string
  default     = true
}

variable "path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "additional_policy_arns" {
  description = "ARNs of additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

################################################################################
# Pod Identity Association
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

################################################################################
# Policies
################################################################################

variable "source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type        = any
  default     = []
}

variable "policy_name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = "AmazonEKS_"
}

# Custom policy
variable "attach_custom_policy" {
  description = "Determines whether to attach the custom IAM policy to the role"
  type        = bool
  default     = false
}

variable "custom_policy_description" {
  description = "Description of the custom IAM policy"
  type        = string
  default     = "Custom IAM Policy"
}

# AWS EBS CSI

variable "create_ebs_csi_resources" {
  description = "Determines whether to create the ebs csi IAM role"
  type        = bool
  default     = false

}
variable "attach_aws_ebs_csi_policy" {
  description = "Determines whether to attach the EBS CSI IAM policy to the role"
  type        = bool
  default     = false
}

variable "aws_ebs_csi_policy_name" {
  description = "Custom name of the EBS CSI IAM policy"
  type        = string
  default     = null
}

variable "aws_ebs_csi_kms_arns" {
  description = "KMS key ARNs to allow EBS CSI to manage encrypted volumes"
  type        = list(string)
  default     = []
}

# Cluster autoscaler



variable "create_cluster_autoscaler_resources" {
  description = "Determines whether to attach the Cluster Autoscaler IAM policy to the role"
  type        = bool
  default     = false
}




variable "attach_cluster_autoscaler_policy" {
  description = "Determines whether to attach the Cluster Autoscaler IAM policy to the role"
  type        = bool
  default     = false
}



variable "cluster_autoscaler_policy_name" {
  description = "Custom name of the Cluster Autoscaler IAM policy"
  type        = string
  default     = null
}

variable "cluster_autoscaler_cluster_names" {
  description = "List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy"
  type        = list(string)
  default     = []
}

### external DNS

variable "create_external_dns_role" {
  description = "Determines whether to create the external dns IAM role"
  type        = bool
  default     = false
}

variable "domain_env" {
  description = "[NONPROD/PROD]Environment value to pick respective Domain name of the Route53 hosted zone to use with External DNS."
  type        = string
  default     = "nonprod"
}

variable "attach_external_dns_policy" {
  description = "Determines whether to attach the External DNS IAM policy to the role"
  type        = bool
  default     = false
}

variable "route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

variable "external_dns_policy_name" {
  description = "Custom name of the External DNS IAM policy"
  type        = string
  default     = null
}

variable "external_dns_role" {
  description = "Enable external dns assumption role"
  type        = string
  default     = ""
}

### efs csi
variable "create_efs_csi_resources" {
  description = "Determines whether to create the EFS CSI IAM role"
  type        = bool
  default     = false

}
variable "attach_aws_efs_csi_policy" {
  description = "Determines whether to attach the EFS CSI IAM policy to the role"
  type        = bool
  default     = false

}

variable "aws_efs_csi_policy_name" {
  description = "Custom name of the EFS CSI IAM policy"
  type        = string
  default     = null
}



### external secrets
variable "create_external_secrets_resources" {
  description = "Determines whether to create the external secrets IAM role"
  type        = bool
  default     = false

}

variable "attach_external_secrets_policy" {
  description = "Determines whether to attach the External Secrets policy to the role"
  type        = bool
  default     = false
}

variable "external_secrets_policy_name" {
  description = "Custom name of the External Secrets IAM policy"
  type        = string
  default     = null
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []

}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []
}


variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []
}

variable "external_secrets_create_permission" {
  description = "Determines whether External Secrets has permission to create/delete secrets"
  type        = bool
  default     = false
}

# AWS Load Balancer Controller
variable "attach_aws_lb_controller_policy" {
  description = "Determines whether to attach the AWS Load Balancer Controller policy to the role"
  type        = bool
  default     = false
}

variable "aws_lb_controller_policy_name" {
  description = "Custom name of the AWS Load Balancer Controller IAM policy"
  type        = string
  default     = null
}

# AWS Load Balancer Controller TargetGroup Binding Only
variable "attach_aws_lb_controller_targetgroup_binding_only_policy" {
  description = "Determines whether to attach the AWS Load Balancer Controller policy for the TargetGroupBinding only"
  type        = bool
  default     = false
}

variable "aws_lb_controller_targetgroup_only_policy_name" {
  description = "Custom name of the AWS Load Balancer Controller IAM policy for the TargetGroupBinding only"
  type        = string
  default     = null
}

variable "aws_lb_controller_targetgroup_arns" {
  description = "List of Target groups ARNs using Load Balancer Controller"
  type        = list(string)
  default     = []
}

variable "create_lb_controller_resources" {
  description = "Determines whether to create the AWS Load Balancer Controller resources"
  type        = bool
  default     = false
}

# AWS VPC CNI
variable "create_vpc_cni" {
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

#fluentbit

variable "create_aws_for_fluentbit_resources" {

  description = "Determines whether to create aws for fluentbit IAM Role"
  type        = bool
  default     = false

}

variable "attach_aws_for_fluentbit_policy" {
  description = "Determines whether to attach the aws for fluentbit policy to the role"
  type        = bool
  default     = false
}

variable "cw_log_group_name" {
  description = "FluentBit CloudWatch Log group name"
  type        = string
  default     = null
}

variable "cw_log_group_retention" {
  description = "FluentBit CloudWatch Log group retention period"
  type        = number
  default     = 90
}

variable "cw_log_group_kms_key_arn" {
  description = "FluentBit CloudWatch Log group KMS Key"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "encrypt_ebs_csi" {
  description = "Determines whether to encrypt EBS volumes created by the EBS CSI driver"
  type        = bool
  default     = false
}