variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
}

variable "custom_codescan_policy_file" {
  description = "add custom codescan policy file for codebuild project, if needed"
  type        = string
  default     = null
}

variable "custom_codepublish_policy_file" {
  description = "add custom codepublish policy file for codebuild project, if needed"
  type        = string
  default     = null
}

variable "region" {
  description = "Region of pipeline stages"
  type        = string
}

variable "repo_name" {
  description = "Github repository name of the application to be built"
  type        = string
  default     = null
}

variable "stages" {
  description = "Further stages after publisg stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars"
  type        = list(any)
  default     = []
}

variable "encryption_key_id" {
  description = "The KMS key ARN or ID for artifact store"
  type        = string
  default     = null
}

variable "artifact_store_region" {
  description = "The region where the artifact store is located. Required for a cross-region CodePipeline, do not provide for a single-region CodePipeline."
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

###support resource varibales
variable "vpc_id" {
  description = "enter the vpc id within which to run builds."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds."
  type        = list(string)
}

variable "nodejs_version" {
  description = "Enter the nodejs version value"
  type        = string
}

variable "nodejs_version_codescan" {
  description = "Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended"
  type        = string
  default     = "20"
  validation {
    condition     = can(regex("(1[8-9]|[2-9][0-9])", var.nodejs_version_codescan))
    error_message = "Minimum of node18 version is required to run sonarscan."
  }
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token of SonarQube stored in secrets manager"
  type        = string
}

variable "sonar_host" {
  description = "Enter the value of SonarQube host"
  type        = string
}

variable "github_branch" {
  description = "Enter the value of github repo branch"
  type        = string
}

variable "project_name" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "project_root_directory" {
  description = "Enter the project root directory value"
  type        = string
}

variable "unit_test_commands" {
  description = "The commands to execute unit tests"
  type        = string
  default     = ""
}

variable "project_unit_test_dir" {
  description = "Enter the name of project unit test directory"
  type        = string
}

variable "github_repo_url" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
  type        = string
}

variable "environment_image_codepublish" {
  description = "Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "environment_type_codepublish" {
  description = "Type of build environment to use for codepublish project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the codepublish project"
  type        = number
  default     = 1
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_image_codescan" {
  description = "Docker image to use for this codescan project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "environment_type_codescan" {
  description = "Type of build environment to use for codescan related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
  default     = "LINUX_CONTAINER"

}

variable "concurrent_build_limit_codescan" {
  description = "Maximum number of concurrent builds for the codescan project"
  type        = number
  default     = 1
}

variable "compute_type_codescan" {
  description = "Information about the compute resources the build project will use in codescan project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "artifact_bucket_owner_access" {
  description = "Enter the artifact bucket owner access"
  type        = string
  default     = "FULL"
}

#variables for aws_iam_role
variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["codebuild.amazonaws.com"]
}

#variables for aws_iam_role
variable "codepipeline_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["codepipeline.amazonaws.com"]
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

variable "sg_name" {
  description = "name of the security group"
  type        = string
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
}
##
variable "kms_key_arn" {
  description = "Enter the KMS key arn for encryption - codebuild"
  type        = string
  default     = null
}

variable "s3_static_web_bucket_name" {
  description = "Enter the bucket name"
  type        = string
}

variable "s3_static_web_bucket_region" {
  description = "Enter the bucket region"
  type        = string
}

variable "aws_cloudfront_distribution_id" {
  description = "aws cloudfront distribution id"
  type        = string
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "pollchanges" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
  type        = string
  default     = "false"
}


variable "cache_type_codescan" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type_codescan == "NO_CACHE" || var.cache_type_codescan == "LOCAL" || var.cache_type_codescan == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location_codescan" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes_codescan" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes_codescan == "LOCAL_SOURCE_CACHE" || var.cache_modes_codescan == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes_codescan == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}

variable "cache_type_codepublish" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type_codepublish == "NO_CACHE" || var.cache_type_codepublish == "LOCAL" || var.cache_type_codepublish == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location_codepublish" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes_codepublish" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes_codepublish == "LOCAL_SOURCE_CACHE" || var.cache_modes_codepublish == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes_codepublish == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}

variable "environment_variables_codescan_stage" {
  description = "Provide the list of environment variables required for codescan stage"
  type        = list(any)
  default     = []
}

variable "environment_variables_codepublish_stage" {
  description = "Provide the list of environment variables required for codepublish stage"
  type        = list(any)
  default     = []
}

##
variable "artifactory_repo_key" {
  description = "JFrog npm Artifactory to use in Terraform CodePipeline to pull the npm dependencies"
  type        = string
  default     = "ccoe-cicd-npm-virtual"
}

variable "artifactory_host" {
  description = "Enter the name of jfrog artifactory host"
  type        = string
  default     = "https://jfrog.io.pge.com"
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
  default     = "jfrog_credentials:jfrog_user"
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token of artifactory stored in secrets manager"
  type        = string
  default     = "jfrog_credentials:jfrog_token"
}
##

variable "custom_codebuild_policy_file" {
  description = "add custom codebuild policy file for codebuild project, if needed"
  type        = string
  default     = null
}

variable "build_args1" {
  description = "Provide the build environment variables required for codebuild"
  type        = string
  default     = ""
}

variable "overwrite_s3_bucket" {
  description = "Enter the type of the codepipeline application"
  type        = string
  default     = "false"
}


