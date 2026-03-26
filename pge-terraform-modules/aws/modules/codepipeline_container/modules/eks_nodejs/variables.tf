# Variables for CodePipeline configuration
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
  description = "The location where AWS CodePipeline pulls artifacts for a pipeline"
  type        = string
  default     = ""
}


variable "role_arn" {
  description = "A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf."
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

variable "artifact_store_location_bucket" {
  description = "The location where AWS CodePipeline stores artifacts for a pipeline; currently only S3 is supported."
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

variable "pollchanges" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected, this uses CodePipeline Polling. Default to false to use webhook."
  type        = string
  default     = "false"
}

variable "stages" {
  description = "Further stages after publish stage can be added in dynamic block. Dynamic stage is also optional when no values are provided in tfvars."
  type        = list(any)
  default     = []
}

variable "Environment" {
  type = string
  validation {
    condition     = contains(["Dev", "QA", "UAT", "PROD"], var.Environment)
    error_message = "Valid values for Environments are Dev, QA, UAT or PROD ."
  }
}

variable "image_type" {
  description = "Application image type"
  type        = string
  default     = "pge-app"
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

# Variables for GitHub configuration
variable "secretsmanager_github_token_secret_name" {
  description = "Secret manager path of the GitHub OAUTH or PAT"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name of the repository, e.g., pgetech, DigitalCatalyst, etc."
  type        = string
}

variable "repo_name" {
  description = "GitHub repository name of the application to be built"
  type        = string
}

variable "branch" {
  description = "Branch of the GitHub repository, e.g., 'master'"
  type        = string
}

variable "acm_certificate_arn" {
  description = "A domain name for which the certificate should be issued"
  type        = string

}

# Variables for CodeBuild configuration
variable "custom_codebuild_policy_file" {
  description = "Add custom CodeBuild policy file for CodeBuild project, if needed"
  type        = string
  default     = null
}

variable "custom_codescan_policy_file" {
  description = "Add custom CodeScan policy file for CodeBuild project, if needed"
  type        = string
  default     = null
}

variable "unit_test_commands" {
  description = "Default is empty as Sonar scan command will be used to run unit tests as well"
  type        = string
  default     = ""
}

variable "source_buildspec_codebuild" {
  description = "Enter the buildspec file of build stage CodeBuild project"
  type        = string
}

variable "environment_variables_codebuild_stage" {
  description = "Provide the list of environment variables required for CodeBuild stage"
  type        = list(any)
  default     = []
}

variable "environment_image_codebuild" {
  description = "Docker image to use for CodeBuild project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for CodeBuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  type        = string
}

variable "source_location_codebuild" {
  description = "Location of the source code from Git or S3 to build CodeScan project."
  type        = string
}

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the project in CodeBuild project"
  type        = number
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in CodeBuild project"
  type        = string
}

# Variables for CodePublish configuration
variable "custom_codepublish_policy_file" {
  description = "Add custom CodePublish policy file for CodeBuild project, if needed"
  type        = string
  default     = null
}

variable "environment_image_codepublish" {
  description = "Docker image to use for this CodePublish project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codepublish" {
  description = "Type of build environment to use for CodePublish project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  type        = string
}

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the CodePublish project"
  type        = number
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in CodePublish project"
  type        = string
}

variable "source_location_codepublish" {
  description = "Location of the source code from Git or S3 for CodePublish."
  type        = string
}

# Variables for CodeScan configuration
variable "environment_image_codescan" {
  description = "Docker image to use for this CodeScan project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codescan" {
  description = "Type of build environment to use for CodeScan related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  type        = string
}

variable "concurrent_build_limit_codescan" {
  description = "Maximum number of concurrent builds for the CodeScan project"
  type        = number
}

variable "compute_type_codescan" {
  description = "Information about the compute resources the build project will use in CodeScan project"
  type        = string
}

variable "source_location_codescan" {
  description = "Location of the source code from Git or S3 to build CodeScan project."
  type        = string
}

variable "environment_variables_codescan_stage" {
  description = "Provide the list of environment variables required for CodeScan stage"
  type        = list(any)
  default     = []
}

# Variables for SonarQube configuration
variable "secretsmanager_sonar_token" {
  description = "Enter the token of SonarQube stored in Secrets Manager"
  type        = string
}

variable "sonar_host" {
  description = "Enter the host value of SonarQube"
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
  description = "Enter the project root directory - variable in buildspec yml"
  type        = string
}

variable "node_runtime" {
  description = "Enter the nodejs runtime version for codebuild stages - variable in buildspec yml"
  type        = string
  default     = null
}
variable "nodejs_runtime" {
  description = "Enter the runtime version of node - variable in buildspec yml"
  type        = string
  default     = null
}

variable "nodejs_runtime_codescan" {
  description = "Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended"
  type        = string
  default     = "20"
  validation {
    condition     = can(regex("(1[8-9]|[2-9][0-9])", var.nodejs_runtime_codescan))
    error_message = "Minimum of node18 version is required to run sonarscan."
  }
}

# Variables for Artifactory configuration
variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of JFrog Artifactory stored in Secrets Manager"
  type        = string
}

variable "artifactory_host" {
  description = "Enter the name of JFrog Artifactory host"
  type        = string
}

variable "artifactory_repo_name" {
  description = "Enter the name value of JFrog Artifactory"
  type        = string
  default     = null
}

variable "artifactory_nodejs_repo" {
  description = "Enter the name value of jfrog artifactory"
  type        = string
  default     = null
}

variable "artifactory_docker_registry" {
  description = "Enter the name value of JFrog Artifactory"
  type        = string
}

variable "artifactory_docker_repo" {
  description = "Enter the name value of jfrog artifactory"
  type        = string
  default     = null
}

variable "artifactory_helm_local_repo" {
  description = "Enter the name value of jfrog artifactory helm chart virtual group name storedin ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of JFrog Artifactory user stored in Secrets Manager"
  type        = string
}

# Variables for wiz configuration
variable "secretsmanager_wiz_client_id" {
  description = "Enter the name of wiz client id stored in secrets manager"
  type        = string
}

variable "secretsmanager_wiz_client_secret" {
  description = "Enter the token of wiz client secret stored in secrets manager"
  type        = string
}

variable "privileged_mode_wizscan" {
  description = "Whether to enable running the Docker daemon inside a Docker container"
  type        = bool
  default     = false
}

variable "environment_variables_wiz_stage" {
  description = "Provide the list of environment variables required for wiz stage"
  type        = list(any)
  default     = []
}

variable "aws_account_number" {
  description = "Enter the provisoninged account number "
  type        = string
}

# Variables for application details
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####"
  type        = number
  default     = 1001
}

variable "container_name" {
  description = "Enter the application container name"
  type        = string
}

variable "publish_docker_registry" {
  description = "Docker registry to publish the image. BOTH will publish the image to both ECR and JFROG. JFROG image will be considered default for the deployment"
  type        = string
  default     = "JFROG"
  validation {
    condition     = contains(["ECR", "JFROG", "BOTH"], var.publish_docker_registry)
    error_message = "Valid values for docker registry are ECR, JFROG, and BOTH."
  }
}

variable "codedeploy_provider" {
  description = "Enter CodeDeploy Provider name for ECS Deployment strategies"
  type        = string
  default     = "ECS"
  validation {
    condition     = contains(["ECS", "CodeDeployToECS"], var.codedeploy_provider)
    error_message = "Valid values for ECS deployement strategies are ECS, CodeDeployToECS."
  }
}

variable "node_build" {
  description = "Build or install command for nodejs webapp"
  type        = string
  default     = null
}

variable "build_command" {
  description = "Build or install command for nodejs webapp"
  type        = string
  default     = null
}

variable "version_file" {
  description = "Enter the name of the file that contains the application version"
  type        = string
}

# Variables for artifact storage
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

# Variables for IAM role
variable "codebuild_role_service" {
  description = "AWS service of the IAM role"
  type        = list(string)
}

variable "tags_codebuild" {
  description = "Tags for CodeBuild projects"
  type        = map(string)
}

# Variables for security group
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
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
}

# Variables for general configuration
variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "Enter the KMS key ARN for encryption - CodeBuild"
  type        = string
  default     = null
}

variable "endpoint_email" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs within which to run builds."
  type        = list(string)
}

variable "vpc_id" {
  description = "Enter the VPC ID within which to run builds."
  type        = string
}

variable "cidr_egress_rules_SNS_codestar" {
  description = "Egress rule for CodeStar"
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

variable "codestar_lambda_encryption_key_id" {
  description = "The KMS key ARN for CodeStar notifications"
  type        = string
  default     = null
}

variable "codestar_environment" {
  description = "codestar environment name"
  type        = string
  default     = "dev"
}

variable "app_owners" {
  description = "underscore separated application development owners"
  type        = string
  default     = "a8dv_su1y_sycz"
}

# Variables for CodeSecret stage
variable "environment_image_codesecret" {
  description = "Docker image to use for CodeBuild project. Valid values include Docker images provided by CodeBuild (e.g., aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codesecret" {
  description = "Type of build environment to use for CodeBuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER."
  type        = string
}

variable "source_location_codesecret" {
  description = "Location of the source code from Git or S3 to build CodeScan project."
  type        = string
}

variable "concurrent_build_limit_codesecret" {
  description = "Maximum number of concurrent builds for the project in CodeBuild project"
  type        = number
}

variable "compute_type_codesecret" {
  description = "Information about the compute resources the build project will use in CodeBuild project"
  type        = string
}

variable "branch_codesecret" {
  description = "Branch of the GitHub repository, e.g., 'master'"
  type        = string
  default     = "main"
}

variable "pollchanges_codesecret" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
  type        = string
  default     = false
}

variable "codestar_sns_kms_key_arn" {
  description = "CodeStar KMS key ARN"
  type        = string
  default     = null
}

# Variables for cache configuration
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

# Boolean flag to determine if the cluster is EKS Fargate. If true, Twistlock defender will be embedded.
variable "is_eks_fargate" {
  description = "To embed Twistlock defender if the cluster is EKS Fargate"
  type        = bool
  default     = true
}