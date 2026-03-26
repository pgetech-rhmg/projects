variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
}

variable "region" {
  description = "Region of pipeline stages"
  type        = string
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "github_org" {
  description = "Github organization name of the repository, pgetech, DigitalCatalyst, etc"
  type        = string
}

variable "repo_name" {
  description = "Github repository name of the application to be built"
  type        = string
}

variable "branch" {
  description = "Branch of the GitHub repository, e.g 'master"
  type        = string
}

variable "pollchanges" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
  type        = string
}

variable "artifact_store_region" {
  description = "The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline."
  type        = string
  default     = null
}

#######codebuild support resources
variable "vpc_id" {
  description = "enter the vpc id within which to run builds."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds."
  type        = list(string)
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of jfrog artifactory stored in secrets manager"
  type        = string
}

variable "artifactory_host" {
  description = "Enter the name of jfrog artifactory host"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "java_runtime" {
  description = "Enter the project root directory - variable in buildspec yml"
  type        = string
}

variable "artifact_bucket_owner_access" {
  description = "Enter the artifact bucket owner access"
  type        = string
  default     = "FULL"
}

variable "artifact_path" {
  description = "Enter the path to store artifact - S3"
  type        = string
}

variable "tags_codebuild" {
  description = "tags for codebuild projects"
  type        = map(string)
}


module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

module "validate_codebuild_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags_codebuild
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
}

variable "aws_account_number" {
  description = "Enter the provisoninged account number "
  type        = string
}

###################### SNS Variables ##############################

variable "endpoint_email" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
  default     = null
}


##################### Lambda variables End ################################

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

variable "notification_message" {
  description = "Enter Approval request notifications message"
  type        = string
}

variable "eks_cluster_name" {
  description = "Enter EKS cluster name"
  type        = string
}

variable "chart_revision" {
  description = "Enter chart_version"
  type        = string
}

variable "container_name" {
  type        = string
  description = "Please enter application name to create images, helm charts and deploy to ECS or EKS"
}

variable "namespace" {
  description = "Enter kubernetes namespace"
  type        = string
}


variable "environment_image_helmchart" {
  description = "Docker image to use for codetest project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_helmchart" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "source_location_helmchart" {
  description = " Location of the source code from git or s3 to build codescan project."
  type        = string
}

variable "concurrent_build_limit_helmchart" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
}

variable "compute_type_helmchart" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
}

######### CodeStar Variables######

variable "cidr_egress_rules_SNS_codestar" {
  description = "egress rule for codestar"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "encryption_key_id" {
  description = "The KMS key ARN or ID for artifact store"
  type        = string
  default     = null
}

variable "artifact_store_location_bucket" {
  description = " The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported."
  type        = string
}

variable "role_arn" {
  description = " A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.role_arn))
    ])
    error_message = "Role_arn is required and the allowed format of 'role_arn' is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}


variable "environment_variables_helmchart_rollback" {
  description = "Provide the list of environment variables required for helmchart_rollback"
  type        = list(any)
  default     = []
}


variable "cache_type_rollback_config" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type_rollback_config == "NO_CACHE" || var.cache_type_rollback_config == "LOCAL" || var.cache_type_rollback_config == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location_rollback_config" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes_rollback_config" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes_rollback_config == "LOCAL_SOURCE_CACHE" || var.cache_modes_rollback_config == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes_rollback_config == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}