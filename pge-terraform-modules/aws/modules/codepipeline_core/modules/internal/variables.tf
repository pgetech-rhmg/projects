variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
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
  description = "The name of the S3 bucket containing the source code artifact for the pipeline."
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

variable "s3_bucket_name" {
  description = "S3 bucket name to download packages to install telerik"
  type        = string
  default     = null
}

variable "install_telerik" {
  description = "weather to install telerik or not"
  type        = string
  default     = "false"
}

variable "telerik_s3_bucket_name" {
  description = "Telerik S3 bucket name to download packages to install telerik"
  type        = string
  default     = ""
}

variable "s3_telerik_file_name" {
  description = "S3 telerik file name to download packages to install telerik"
  type        = string
  default     = "telerik.ui.for.blazor.2.28.0.commercial.msi.zip"
}

variable "s3_telerik_extract_path" {
  description = "S3 telerik extract path to download packages to install telerik"
  type        = string
  default     = "telerik.ui.for.blazor.2.28.0.commercial.msi"
}

variable "install_dotnet9" {
  description = "Whether to install dotnet9 or not"
  type        = string
  default     = "false"
}

variable "unit_test_commands" {
  description = "Enter the unit test commands for python webapp"
  type        = string
  default     = ""
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
  default     = ""
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
  default     = ""
}

variable "github_branch" {
  description = "Enter the value of github repo branch - environment variable used in buildspec yml"
  type        = string
  default     = ""
}

variable "python_runtime" {
  description = "Enter the python version to compile application code - variable in buildspec yml"
  type        = string
  default     = "3.9"
}

variable "node_runtime" {
  description = "Enter the node version to compile application code - variable in buildspec yml"
  type        = string
  default     = "16"
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

variable "artifact_name_nodejs" {
  description = "Enter the name of artifact"
  type        = string
  default     = null
}

variable "dotnet_runtime" {
  description = "Enter the dotnet version to compile application code - variable in buildspec yml"
  type        = string
  default     = "6.0"
}

variable "java_runtime" {
  description = "Enter the java runtime version for build satges - variable in buildspec yml"
  type        = string
  default     = "corretto17"
}

variable "java_runtime_codescan" {
  description = "Enter the java runtime version for codescan stage, Minimum of java17 version is required to run sonarscan - variable in buildspec yml"
  type        = string
  default     = "corretto17"
  validation {
    condition     = can(regex("^corretto(1[7-9]|[2-9][0-9])$", var.java_runtime_codescan))
    error_message = "Minimum of java17 version is required to run sonarscan."
  }
}

#varibales for module codebuild projects
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

variable "source_location_codebuild" {
  description = " Location of the source code from git or s3 to build codescan project."
  type        = string
  default     = null
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
  default     = "1"
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
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
  default     = null
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

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
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
  default     = ""
}

variable "lambda_alias_name" {
  description = "Enter the name of the Lambda alias"
  type        = string
  default     = ""
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

variable "source_location_codepublish" {
  description = " Location of the source code from git or s3 for codepublish."
  type        = string
  default     = null
}

variable "source_location_codescan" {
  description = " Location of the source code from git or s3 for codescan."
  type        = string
  default     = null
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

variable "codebuildapp_language" {
  description = "Enter the type of the codepipeline application"
  type        = string
  default     = null
}

variable "exclude_files" {
  description = "space separated files/folders that should not be added to the Lambda function"
  type        = string
  default     = ""
}

variable "lambda_update" {
  description = "Input from the user to update lambda function with zip created or not"
  type        = bool
  default     = false
}

variable "dotnet_project_metadata_file" {
  description = "Name of the file that includes dotnet project's metadata and dependencies"
  type        = string
  default     = "appsettings.json"
}

variable "sonar_scanner_cli_version" {
  description = "The version of sonar-scanner CLI binary to download. Default is the latest version."
  type        = string
  default     = "5.0.1.3006"
}

#download artifact
variable "download_artifact" {
  description = "Download artifact from jfrog, creates a pipeline with few stages to download artifact from artifactory and skips build, sonarscan, publish stages etc. This is only for QA or prod environments."
  type        = bool
  default     = false
}

#####

variable "sonar_branch_scanned" {
  description = "branch that has already been scanned with artifactory to check QG status on sonarqube and skip sonarscan rerun, requires only when download_artifact is true "
  type        = string
  default     = ""
}

variable "custom_codedownload_policy_file" {
  description = "add custom codedownload policy file for codebuild project, if needed"
  type        = string
  default     = null
}

#### New variables for download Artifact:

variable "environment_image_codedownload" {
  description = "Docker image to use for this codedownload project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
  default     = null
}

variable "environment_type_codedownload" {
  description = "Type of build environment to use for codedownload project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
  default     = null
}

variable "source_location_codedownload" {
  description = " Location of the source code from git or s3 for codedownload."
  type        = string
  default     = null
}

variable "concurrent_build_limit_codedownload" {
  description = "Maximum number of concurrent builds for the codedownload project"
  type        = number
  default     = null
}

variable "compute_type_codedownload" {
  description = "Information about the compute resources the build project will use in codedownload project"
  type        = string
  default     = null
}

variable "environment_variables_codedownload_stage" {
  description = "Provide the list of environment variables required for codedownload stage"
  type        = list(any)
  default     = []
}

variable "cache_type_codedownload" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
  default     = "NO_CACHE"
  validation {
    condition     = var.cache_type_codedownload == "NO_CACHE" || var.cache_type_codedownload == "LOCAL" || var.cache_type_codedownload == "S3"
    error_message = "Valid values are NO_CACHE, LOCAL, S3."
  }
}

variable "cache_location_codedownload" {
  description = "Location where the AWS CodeBuild project stores cached resources"
  type        = string
  default     = null
}

variable "cache_modes_codedownload" {
  description = "Specifies settings that AWS CodeBuild uses to store and reuse build dependencies"
  type        = string
  default     = "LOCAL_SOURCE_CACHE"
  validation {
    condition     = var.cache_modes_codedownload == "LOCAL_SOURCE_CACHE" || var.cache_modes_codedownload == "LOCAL_DOCKER_LAYER_CACHE" || var.cache_modes_codedownload == "LOCAL_CUSTOM_CACHE"
    error_message = "Valid values are LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, LOCAL_CUSTOM_CACHE."
  }
}

variable "artifact_version" {
  description = "Enter the artifact version"
  type        = string
  default     = null
}

variable "project_unit_test_dir" {
  description = "Enter the name of project unit test directory"
  type        = string
  default     = null
}

variable "project_file_location" {
  description = "Enter the project file location value"
  type        = string
  default     = null
}

# Windows build support variables
variable "enable_windows_build" {
  description = "Enable Windows build environment for .NET projects"
  type        = bool
  default     = false
}

variable "project_file" {
  description = "The path to the project file for the build process."
  type        = string
  default     = ""
}

variable "environment_image_codebuild_windows" {
  description = "Docker image to use for Windows codebuild project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codescan_windows" {
  description = "Docker image to use for Windows codescan project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codepublish_windows" {
  description = "Docker image to use for Windows codepublish project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codedownload_windows" {
  description = "Docker image to use for Windows codedownload project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "windows_environment_type" {
  description = "Windows environment type for CodeBuild projects. Valid values: WINDOWS_SERVER_2019_CONTAINER, WINDOWS_SERVER_2022_CONTAINER."
  type        = string
  default     = "WINDOWS_SERVER_2019_CONTAINER"
  validation {
    condition     = contains(["WINDOWS_SERVER_2019_CONTAINER", "WINDOWS_SERVER_2022_CONTAINER"], var.windows_environment_type)
    error_message = "Valid values for windows_environment_type are 'WINDOWS_SERVER_2019_CONTAINER' or 'WINDOWS_SERVER_2022_CONTAINER'."
  }
}

variable "sonar_exclusion_list" {
  description = "List of files and directories to exclude from SonarQube analysis."
  type        = string
  default     = "**/*.txt"
}

