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

################################################################################
# EKS Pod Identity
################################################################################
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

variable "domain_env" {
  description = "Enable external dns add-on"
  type        = string
  default     = "nonprod"
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

variable "create_custom_role" {
  description = "Determines whether to create the custom IAM role"
  type        = bool
  default     = false
}

variable "create_cloudwatch_agent" {
  description = "Create cloudwatch agent for eks cluster"
  type        = bool
}

variable "create_aws_for_fluentbit_resources" {
  description = "Determines whether to create aws for fluentbit IAM Role"
  type        = bool
  default     = false
}

variable "hosted_zone" {
  description = "Route53 hosted zone name"
  type        = string
  default     = ""
}
variable "account_num_r53" {
  description = "Route53 account number"
  type        = string
  default     = "514712703977"
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
