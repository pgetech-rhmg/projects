#variables for aws_codebuild_project
variable "codebuild_project_name" {
  description = "The name of Project"
  type        = string
}

variable "codebuild_project_role" {
  description = "IAM role that enables AWS CodeBuild to interact with dependent AWS services"
  type        = string
}

variable "badge_enabled" {
  description = "Generates a publicly-accessible URL for the projects build badge"
  type        = bool
  default     = false
}

variable "codebuild_project_build_timeout" {
  description = " Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
  type        = number
  default     = 60
  validation {
    condition     = var.codebuild_project_build_timeout >= 5 && var.codebuild_project_build_timeout <= 480
    error_message = "Valid values are from 5 to 480."
  }
}

variable "concurrent_build_limit" {
  description = "Maximum number of concurrent builds for the project"
  type        = number
  validation {
    condition     = var.concurrent_build_limit > 0 && var.concurrent_build_limit <= 60
    error_message = "Value must be greater than 0 and less than the account concurrent running builds limit."
  }
}

variable "codebuild_project_description" {
  description = "Short description of the project"
  type        = string
  default     = null
}

variable "encryption_key" {
  description = " KMS used for encrypting the build project's build output artifacts"
  type        = string
  default     = null
}

variable "project_visibility" {
  description = "Specifies the visibility of the project's builds"
  type        = string
  default     = "PRIVATE"
  validation {
    condition     = var.project_visibility == "PUBLIC_READ" || var.project_visibility == "PRIVATE"
    error_message = "Valid values are PUBLIC_READ and PRIVATE."
  }
}

variable "resource_access_role" {
  description = "The ARN of the IAM role that enables CodeBuild to access the CloudWatch Logs and Amazon S3 artifacts"
  type        = string
  default     = null
}

variable "queued_timeout" {
  description = "  Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out"
  type        = number
  default     = 480
  validation {
    condition     = var.queued_timeout >= 5 && var.queued_timeout <= 480
    error_message = "Valid values are from 5 to 480."
  }
}

variable "source_version" {
  description = "Version of the build input to be built for this project"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#aws_codebuild_project- artifacts
variable "artifact_identifier" {
  description = "Artifact identifier"
  type        = string
  default     = null
}

variable "artifact_bucket_owner_access" {
  description = "Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket"
  type        = string
  default     = null
  validation {
    condition     = var.artifact_bucket_owner_access == "NONE" || var.artifact_bucket_owner_access == "READ_ONLY" || var.artifact_bucket_owner_access == "FULL" || var.artifact_bucket_owner_access == null
    error_message = "Valid values are NONE, READ_ONLY, and FULL."
  }
}

variable "artifact_location" {
  description = "Build output artifact location"
  type        = string
  default     = null
}

variable "artifact_name" {
  description = "Name of the project"
  type        = string
  default     = null
}

variable "artifact_namespace_type" {
  description = "Namespace to use in storing build artifacts"
  type        = string
  default     = null
}

variable "artifact_override_name" {
  description = "Whether a name specified in the build specification overrides the artifact name"
  type        = string
  default     = null
}

variable "artifact_packaging" {
  description = "Type of build output artifact to create.If type is set to S3, valid values are NONE, ZIP."
  type        = string
  default     = null
  validation {
    condition     = var.artifact_packaging == "ZIP" || var.artifact_packaging == "NONE" || var.artifact_packaging == null
    error_message = "Valid values are NONE, ZIP."
  }
}

variable "artifact_path" {
  description = "If type is set to S3, this is the path to the output artifact"
  type        = string
  default     = null
}

variable "artifact_type" {
  description = "Build output artifact's type"
  type        = string
  validation {
    condition     = var.artifact_type == "CODEPIPELINE" || var.artifact_type == "NO_ARTIFACTS" || var.artifact_type == "S3"
    error_message = "Valid values are CODEPIPELINE, NO_ARTIFACTS, S3."
  }
}

#aws_codebuild_project- environments
variable "environment_certificate" {
  description = "ARN of the S3 bucket"
  type        = string
  default     = null
}

variable "compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
  validation {
    condition     = var.compute_type == "BUILD_GENERAL1_SMALL" || var.compute_type == "BUILD_GENERAL1_MEDIUM" || var.compute_type == "BUILD_GENERAL1_LARGE" || var.compute_type == "BUILD_GENERAL1_2XLARGE"
    error_message = "Valid values are BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE."
  }
}

variable "image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build"
  type        = string
  default     = null
  validation {
    condition     = var.image_pull_credentials_type == "CODEBUILD" || var.image_pull_credentials_type == "SERVICE_ROLE" || var.image_pull_credentials_type == null
    error_message = "Valid values are CODEBUILD, SERVICE_ROLE."
  }
}

variable "environment_image" {
  description = "Docker image to use for this build project"
  type        = string
}

variable "environment_privileged_mode" {
  description = "Whether to enable running the Docker daemon inside a Docker container"
  type        = bool
  default     = false
}

variable "environment_type" {
  description = "Type of build environment to use for related builds"
  type        = string
  validation {
    condition     = var.environment_type == "LINUX_CONTAINER" || var.environment_type == "LINUX_GPU_CONTAINER" || var.environment_type == "WINDOWS_CONTAINER" || var.environment_type == "WINDOWS_SERVER_2019_CONTAINER" || var.environment_type == "WINDOWS_SERVER_2022_CONTAINER" || var.environment_type == "ARM_CONTAINER"
    error_message = "Valid values are LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, WINDOWS_SERVER_2022_CONTAINER, ARM_CONTAINER."
  }
}

#aws_codebuild_project- dynamic environment variable
variable "environment_variables" {
  description = "List of nested attributes"
  type        = list(any)
  default     = []
}

#aws_codebuild_project- dynamic registry_credential
variable "environment_credential" {
  description = "ARN or name of credentials created using AWS Secrets Manager"
  type        = string
  default     = null
}

#aws_codebuild_project - source
variable "source_buildspec" {
  description = "Build specification to use for this build project's related builds"
  type        = string
  default     = null
}

variable "source_git_clone_depth" {
  description = "Truncate git history to this many commits"
  type        = number
  default     = 0
}

variable "source_location" {
  description = "Location of the source code from git or s3"
  type        = string
  default     = null
}

variable "source_report_build_status" {
  description = "Whether to report the status of a build's start and finish to your source provider"
  type        = string
  default     = null
}

variable "source_type" {
  description = "Type of repository that contains the source code to be built"
  type        = string
  default     = "NO_SOURCE"
  validation {
    condition     = var.source_type == "CODECOMMIT" || var.source_type == "CODEPIPELINE" || var.source_type == "GITHUB" || var.source_type == "GITHUB_ENTERPRISE" || var.source_type == "BITBUCKET" || var.source_type == "S3" || var.source_type == "NO_SOURCE"
    error_message = "Valid value are CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE."
  }
}

#aws_codebuild_project- dynamic git_submodules_config
variable "source_fetch_sub" {
  description = "Whether to fetch Git submodules for the AWS CodeBuild build project"
  type        = bool
  default     = false
}

#aws_codebuild_project- dynamic build_batch_config
variable "build_batch_artifacts" {
  description = "Specifies if the build artifacts for the batch build should be combined into a single artifact location"
  type        = string
  default     = null
}

variable "build_batch_service_role" {
  description = "Specifies the service role ARN for the batch build project"
  type        = string
  default     = null
}

variable "build_batch_timeout" {
  description = "Specifies the maximum amount of time, in minutes, that the batch build must be completed in"
  type        = number
  default     = null
}

#aws_codebuild_project- dynamic restrictions
variable "compute_types_allowed" {
  description = "An array of strings that specify the compute types that are allowed for the batch build"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cta in var.compute_types_allowed : contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_2XLARGE"], cta)
    ])
    error_message = "Error! values for compute_types_allowed are BUILD_GENERAL1_SMALL, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_2XLARGE."
  }
}

variable "maximum_builds_allowed" {
  description = "Specifies the maximum number of builds allowed"
  type        = number
  default     = null
}

#aws_codebuild_project- cache
variable "cache_type" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type == "NO_CACHE" || var.cache_type == "LOCAL" || var.cache_type == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes == "LOCAL_SOURCE_CACHE" || var.cache_modes == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}

#aws_codebuild_project- dynamic file_system_locations
variable "file_system_locations" {
  description = " A set of file system locations to to mount inside the build"
  type        = map(string)
  default     = {}
}

#aws_codebuild_project- logs_config
variable "cloudwatch_logs_group_name" {
  description = "Name of the S3 bucket and the path prefix for S3 logs"
  type        = string
  default     = null
}

variable "cloudwatch_logs_stream_name" {
  description = "Name of the S3 bucket and the path prefix for S3 logs"
  type        = string
  default     = null
}

#aws_codebuild_project- dynamic s3_logs
variable "s3_location" {
  description = "Name of the S3 bucket and the path prefix for S3 logs"
  type        = string
  default     = null
}

variable "s3_logs_status" {
  description = "Current status of logs in S3 for a build project"
  type        = string
  default     = "DISABLED"
  validation {
    condition     = var.s3_logs_status == "ENABLED" || var.s3_logs_status == "DISABLED"
    error_message = "Valid value are ENABLED, DISABLED."
  }
}

variable "s3_bucket_owner_access" {
  description = "Specifies the bucket owner's access for objects that another account uploads to their Amazon S3 bucket"
  type        = string
  default     = "NONE"
  validation {
    condition     = var.s3_bucket_owner_access == "NONE" || var.s3_bucket_owner_access == "READ_ONLY" || var.s3_bucket_owner_access == "FULL"
    error_message = "Valid value are NONE, READ_ONLY, and FULL."
  }
}

#aws_codebuild_project- dynamic secondary_artifacts
variable "secondary_artifacts" {
  description = "Configuration block for secondary artifacts"
  type        = any
  default     = []
}

#aws_codebuild_project- dynamic secondary_sources
variable "secondary_sources" {
  description = "Configuration block for secondary sources"
  type        = any
  default     = []
}

#aws_codebuild_project- dynamic build_status_config
variable "build_status_config" {
  description = "Configuration block for build_status_config"
  type        = any
  default     = []
}

#aws_codebuild_project- dynamic secondary_source_version
variable "secondary_source_version" {
  description = "Configuration block for secondary source version"
  type        = any
  default     = []
}

#aws_codebuild_project- dynamic vpc_config
variable "vpc_id" {
  description = "ID of the VPC within which to run builds"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to assign to running builds"
  type        = list(string)
}

#variables for aws_codebuild_resource_policy
variable "codebuild_resource_policy" {
  description = "Policy file"
  type        = string
  default     = "{}"
  validation {
    condition     = can(jsondecode(var.codebuild_resource_policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON policy."
  }
}

variable "codebuild_sc_token" {
  description = "ARN of the GitHub Secrets Manager containing the OAUTH or PAT"
  type        = string
}