variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to these resources which indicates their provenance."
  default     = {}
}

variable "project_name" {
  type        = string
  description = "The name of the project."
}

variable "repo_name" {
  type        = string
  description = "The name of the GitHub repository inside the PGEDigitalCatalyst organization. If unset, defaults to `project_name`."
  default     = ""
}

variable "branch" {
  type        = string
  description = "The name of the git branch this CodePipeline is configured to build. Usually you should set this to `var.TFC_CONFIGURATION_VERSION_GIT_BRANCH`. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod`"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume. This parameter is **deprecated.**"
}

variable "github_secret" {
  type        = string
  description = "The name of the AWS Secrets Manager secret containing the GitHub Personal Access Token"
}

variable "github_org" {
  type        = string
  description = "The GitHub organization that owns the repository."
  default     = "PGEDigitalCatalyst"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption. Required if data classification is not Internal or Public."
  default     = null
}

variable "buildspec_build" {
  description = "The CodeBuild buildspec inside the repo used to build the app code and run tests."
  type        = string
  default     = "buildspecs/buildspec-build.yml"
}

variable "buildspec_deploy" {
  description = "The type of deployment this CodePipeline instance will be configured to perform in the final step. `LAMBDA` and `ECS` are built-in, while `REPO` allows the repo owner to configure this as a custom step by adding `buildspecs/buildspec-deploy.yml` to the host repo."
  type        = string
  validation {
    condition     = contains(["LAMBDA", "ECS", "REPO"], var.buildspec_deploy)
    error_message = "Must be one of LAMBDA, ECS, or REPO"
  }
}

variable "partner" {
  type        = string
  description = "The name of the partner team that owns this pipeline."
  default     = "MRAD"
}

variable "vpc" {
  type        = string
  description = "If `partner` is not MRAD, the name of the VPC to use for each CodeBuild step."
  default     = ""
}

variable "subnet1" {
  type        = string
  description = "The name of the first subnet to use for each CodeBuild step."
  default     = ""
}

variable "subnet2" {
  type        = string
  description = "The name of the second subnet to use for each CodeBuild step."
  default     = ""
}

variable "subnet3" {
  type        = string
  description = "The name of the third subnet to use for each CodeBuild step."
  default     = ""
}

variable "sonarqube_secret_name" {
  description = "The ID of the AWS Secrets Manager entry that contains the SonarQube token."
  type        = string
  default     = "sonarqube-mrad"
}

variable "sonar_host" {
  description = "The SonarQube host to which we submit code for analysis."
  type        = string
  default     = "https://sonarqube.io.pge.com"
}

variable "sonar_project_key_prefix" {
  description = "The project key used to prefix our SonarQube reports."
  type        = string
  default     = "mrad"
}

variable "sonar_scanner_cli_zip_url" {
  description = "The URL for the `sonar-scanner-cli` zip for Linux hosted on `binaries.sonarsource.com`. If unset, fetch this URL from AWSSM Parameter Store. Example value: `https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip`"
  type        = string
  default     = ""
}

variable "codebuild_image" {
  description = "Docker image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "docker_node_base_image" {
  description = "The base name for the current MRAD Docker node base image, i.e. `development` -> `990878119577.dkr.ecr.us-west-2.amazonaws.com/docker-node-baseimage-ecs-development:latest`"
  type        = string
  default     = "docker-node-baseimage-ecs"
}

variable "docker_node_base_image_tag" {
  description = "The tag for the current MRAD Docker node base image, i.e. `latest` -> `990878119577.dkr.ecr.us-west-2.amazonaws.com/docker-node-baseimage-ecs-development:latest`"
  type        = string
  default     = "latest"
}

variable "ecr_repo_urls" {
  description = "The ECR repos where we will push the container images after we build them"
  type        = map(any)
  default     = null
}

variable "poll_for_source_changes" {
  description = "When true, AWS uses polling to discover changes to the source repository. See: https://docs.aws.amazon.com/codepipeline/latest/userguide/update-change-detection.html"
  type        = bool
  default     = false
}

variable "tfc_token_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing the Terraform Cloud API token."
  type        = string
  default     = "mrad-tfc-token"
}

variable "enable_tfc_check" {
  description = "If true, insert a step that waits for any TFC runs associated with this commit to complete before proceeding. If false, omit this step. If unset, this check will only be added to pipelines for dev/QA/prod environments."
  type        = bool
  default     = null
}

variable "privileged_deploy_stage" {
  description = "If true, use privileged mode for the deploy stage. Required when building a Docker image."
  type        = bool
  default     = false
}

variable "buildspec_wiz" {
  description = "Optional override for the Wiz buildspec, which builds, scans and pushes Docker images"
  type        = string
  default     = null
}

variable "ci_enable" {
  description = "If true, enable CI. CodeBuild will run on every commit and inside PRs."
  type        = bool
  default     = true
}

variable "ci_type" {
  description = "The AWS CodeBuild Lambda type to use for CI builds. You probably want `LINUX_LAMBDA_CONTAINER` (preferred) or `LINUX_CONTAINER` (for fallback to ECS). See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html"
  type        = string
  default     = "LINUX_LAMBDA_CONTAINER"
}

variable "ci_compute_type" {
  description = "The AWS CodeBuild Lambda compute type to use for CI builds. Must be compatible with `ci_type`. See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html"
  type        = string
  default     = "BUILD_LAMBDA_1GB"
}

variable "ci_image" {
  description = "The AWS CodeBuild Lambda image to use for CI builds. Must be compatible with `ci_type`. See: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html#lambda-compute-images"
  type        = string
  default     = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
}

variable "buildspec_ci" {
  description = "The buildspec to use for CI builds. Defaults to the same value as `buildspec_build`."
  type        = string
  default     = null
}

variable "account_num" {
  # Predefined in TFC
  type        = string
  description = "Target AWS account number - predefined in TFC"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory for r53"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume for r53"
}

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type    = string
  default = null
}
