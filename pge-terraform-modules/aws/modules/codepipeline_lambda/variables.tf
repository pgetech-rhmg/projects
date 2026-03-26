variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
  default     = ""
}

variable "source_type" {
  description = "The source type for the pipeline (GitHub or S3)"
  type        = string
  default     = "GitHub"
  validation {
    condition     = contains(["GitHub", "S3"], var.source_type)
    error_message = "Valid values for source_type are 'GitHub' or 'S3'."
  }
}

variable "s3_object_key" {
  description = "The S3 object key for the source artifact (e.g., source.zip)"
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "The location where AWS CodePipeline pulls artifacts for a pipeline"
  type        = string
  default     = ""
}

variable "custom_codebuild_policy_file" {
  description = "add custom codebuild policy file for codebuild project, if needed"
  type        = string
  default     = null
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

variable "region" {
  description = "Region of pipeline stages"
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
  description = "Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook"
  type        = string
  default     = "false"
}

variable "stages" {
  description = "Further stages after publisg stage can be added in dynamic block. Dynamic stage is also optional when no values is provided in tfvars"
  type        = list(any)
  default     = []
}

variable "artifact_store_location_bucket" {
  description = " The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported."
  type        = string
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

#######codebuild support resources
variable "vpc_id" {
  description = "enter the vpc id within which to run builds."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds."
  type        = list(string)
}

variable "artifactory_host" {
  description = "Enter the name of jfrog artifactory host - environment variable used in buildspec yml"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of jfrog artifactory stored in secrets manager"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token of SonarQube stored in secrets manager"
  type        = string
}

variable "unit_test_commands" {
  description = "Enter the unit test commands for python webapp"
  type        = string
}

variable "sonar_host" {
  description = "Enter the host value of SonarQube"
  type        = string
}

variable "github_repo_url" {
  description = "Enter the github repo url - environment variable used in buildspec yml"
  type        = string
  default     = ""
}

variable "dependency_files_location" {
  description = "Enter the dependency file location - environment variable used in buildspec yml"
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

variable "artifactory_repo_name" {
  description = "Enter the artifact repo name of jfrog - environment variable used in buildspec yml"
  type        = string
}

variable "github_branch" {
  description = "Enter the value of github repo branch - environment variable used in buildspec yml"
  type        = string
}

variable "python_runtime" {
  description = "Enter the python version to compile application code - variable in buildspec yml"
  type        = string
}

#varibales for module codebuild projects
variable "environment_image_codebuild" {
  description = "Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "source_location_codebuild" {
  description = " Location of the source code from git or s3 to build codescan project."
  type        = string
}

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
}

variable "environment_image_codepublish" {
  description = "Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codepublish" {
  description = "Type of build environment to use for codepublish project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the codepublish project"
  type        = number
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
  type        = string
}

variable "environment_image_codescan" {
  description = "Docker image to use for this codescan project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codescan" {
  description = "Type of build environment to use for codescan related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "concurrent_build_limit_codescan" {
  description = "Maximum number of concurrent builds for the codescan project"
  type        = number
}

variable "compute_type_codescan" {
  description = "Information about the compute resources the build project will use in codescan project"
  type        = string
}

variable "artifact_location" {
  description = "Enter the bucket name used for artifact storage"
  type        = string
}

variable "artifact_bucket_owner_access" {
  description = "Enter the artifact bucket owner access"
  type        = string
}

variable "artifact_path" {
  description = "Enter the path to store artifact - S3"
  type        = string
}

variable "source_buildspec_codebuild" {
  description = "Enter the buildspec file of build stage codebuild project"
  type        = string
}

variable "environment_variables_codebuild_stage" {
  description = "Provide the list of environment variables required for codebuild stage"
  type        = list(any)
  default     = []
}

#variables for aws_iam_role
variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  tags    = var.tags
  version = "0.1.2"
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

variable "lambda_function_name" {
  description = "Enter the name of the Lambda Function"
  type        = string
}

variable "lambda_alias_name" {
  description = "Enter the name of the Lambda alias"
  type        = string
}

variable "include_lib_files" {
  description = "Set it to false if lib files need not to be added"
  type        = bool
  default     = true
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
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

variable "sonar_scanner_cli_version" {
  description = "The version of sonar-scanner CLI binary to download. Default is the latest version."
  type        = string
  default     = "5.0.1.3006"
}

variable "lambda_update" {
  description = "Input from the user to update lambda function with zip created or not"
  type        = bool
  default     = true
}