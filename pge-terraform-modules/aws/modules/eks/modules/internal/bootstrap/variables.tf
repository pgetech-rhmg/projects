variable "encryption_key_id" {
  description = "Enter the KMS key arn for encryption - uses for both codepipeline and codebuild"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "Enter the aws region"
  type        = string
  default     = "us-west-2"
}

variable "aws_r53_role" {
  description = "AWS role to assume for Route53"
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number for Route53, mandatory"
}

variable "pollchanges" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook"
  type        = string
  default     = "false"
}

#######codebuild support resources
variable "vpc_id" {
  description = "enter the value of vpc id"
  type        = string
}

variable "subnet_ids" {
  description = "enter the list of 3 subnet id's"
  type        = list(string)
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

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
  default     = "1"
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "cache_type_codebuild" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type_codebuild == "NO_CACHE" || var.cache_type_codebuild == "LOCAL" || var.cache_type_codebuild == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location_codebuild" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes_codebuild" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes_codebuild == "LOCAL_SOURCE_CACHE" || var.cache_modes_codebuild == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes_codebuild == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}

variable "custom_codebuild_policy_file" {
  description = "add custom codebuild policy file for codebuild project, if needed"
  type        = string
  default     = null
}

#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#variables for security_group_project
variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}

variable "cluster_name" {
  description = "Enter the name of the eks cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Enter the name of the eks cluster endpoint"
  type        = string
}

variable "create_cloudwatch_agent" {
  description = "Create cloudwatch agent for eks cluster"
  type        = bool
  default     = false
}
variable "create_metrics_server" {
  description = "Create metrics server adddon for eks cluster"
  type        = bool
  default     = true
}

variable "elasticsearch_enabled" {
  description = "Enable elasticsearch for eks cluster"
  type        = bool
  default     = false
}

variable "elasticsearch_host" {
  description = "Enter the elasticsearch host"
  type        = string
  default     = ""
}

variable "elasticsearch_port" {
  description = "Enter the elasticsearch port"
  type        = number
  default     = 0
}

variable "elasticsearch_index" {
  description = "Enter the elasticsearch index"
  type        = string
  default     = ""
}

variable "elasticsearch_user" {
  description = "Enter the elasticsearch user"
  type        = string
  default     = ""
}

variable "elasticsearch_password_location" {
  description = "Enter the elasticsearch password location"
  type        = string
  default     = ""
}
variable "external_dns_role" {
  description = "Pass external dns assumption role to be used for cross account access"
  type        = string
  default     = ""
}

variable "domain_env" {
  description = "Enable external dns add-on"
  type        = string
  default     = "nonprod"
}

variable "acm_certificate_arn" {
  description = "Enter the ACM certificate arn"
  type        = string
}

variable "subnet_id_list" {
  description = "Enter the subnet id list string"
  type        = string
  default     = ""
}

variable "hosted_zone" {
  description = "Enter the hosted zone"
  type        = string
}

variable "auto_mode_enabled" {
  description = "Enable auto mode for the bootstrap process"
  type        = bool
  default     = false
}

variable "bootstrap_repo_url" {
  description = "URL of the repository containing bootstrap scripts and ArgoCD manifests"
  type        = string
  default     = null
}

variable "bootstrap_repo_ref" {
  description = "Git reference (branch/tag) to use from the bootstrap repository"
  type        = string
  default     = "main"
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
  description = "URL of the custom repository to be used in the bootstrap process"
  type        = string
  default     = null
}

variable "custom_repo_branch" {
  description = "name of the branch to be used in the bootstrap process"
  type        = string
  default     = "main"
}