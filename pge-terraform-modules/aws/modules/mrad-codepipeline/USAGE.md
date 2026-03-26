# mrad-codepipeline v1

mrad-codepipeline creates an instance of
[AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
to test your application code and deploy it to production. It also configures
[AWS CodeBuild](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
unit tests to run in GitHub PRs.

# Installation

_See full working examples:_

- [examples/codepipeline_dockerbuild](examples/codepipeline_dockerbuild/main.tf):
  this CodePipeline module on its own
- [Lambdas-TFC-Example](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/blob/development/terraform/code/main.tf):
  deploy a Lambda function using this CodePipeline module
- [ECS-TFC-Example](https://github.com/PGEDigitalCatalyst/ECS-TFC-Example/blob/development/terraform/code/main.tf):
  deploy an ECS instance using this CodePipeline module

Add the module to your repo along with its supporting code:

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Authenticate to AWS
data "aws_caller_identity" "current" {}
provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

# Authenticate to GitHub to configure webhooks
data "aws_secretsmanager_secret" "github_token" {
  name = local.github_token_secret_name
}
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}
provider "github" {
  owner = "PGEDigitalCatalyst"
  token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
}

locals {
  aws_account = {
    "990878119577" = "Dev"
    "991535610078" = "Test"
    "471817339124" = "QA"
    "712640766496" = "Prod"
  }[var.account_num]

  branch = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH == null ? terraform.workspace : {
    Dev  = "development"
    Test = "test"
    QA   = "main" # or "master"
    Prod = "production"
  }[local.aws_account]

  # The name of the Secrets Manager secret containing the GitHub token
  github_token_secret_name = "MRAD_GITHUB_TOKEN"
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.0.5"

  AppID              = 1795
  Environment        = local.aws_account
  DataClassification = "Internal"
  CRIS               = "Medium"
  Notify             = ["MRAD@pge.com"]
  Owner              = ["A1P2", "S2RB", "JVCW"]
  Compliance         = ["None"]
}

module "pipeline" {
  source  = "app.terraform.io/pgetech/mrad-codepipeline/aws"
  version = "~> 1.0"
  tags    = module.tags.tags

  buildspec_deploy = "LAMBDA"                                     # or "ECS" or "REPO"
  ci_enable        = !contains(["Prod", "QA"], local.aws_account) # CI is not currently supported in QA/Prod due to Sentinel policy issues
  project_name     = "my-repository"                              # The name of this GitHub repository. Case-sensitive.
  branch           = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  aws_account      = local.aws_account
  aws_role         = var.aws_role
  github_secret    = local.github_token_secret_name
}
```

Wire your repo and branch up to a PG&E TFC workspace by adding an entry to
[an MRAD YAML file](https://github.com/pgetech/pge-tfc-workspaces/blob/main/workspaces-aws/wsv2-05/mrad-02.yaml),
then follow the directions in the repo to open a PR
([example](https://github.com/pgetech/pge-tfc-workspaces/pull/1200)).

Once your workspace exists, go to
[PG&E TFC](https://app.terraform.io/app/pgetech/workspaces/), find your
workspace, and start a new Apply Run if it hasn't automatically been started.
From this point forward, all commits to your branch will be automatically
planned and applied in your TFC workspace.

# Usage

Configure the MRAD CodePipeline module by setting its variables in your
Terraform file ([documentation](variables.tf)), committing your values to your
branch, and pushing to GitHub.

## Buildspecs

The CodeBuild stages that make up your CodePipeline instance have code defined
in a
[Buildspec](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html).
This is a YAML file that contains instructions and commands for CodeBuild to
run. Each CodeBuild stage has its own Buildspec.

Buildspecs are defined either in [this module](codebuild_buildspec) or in your
repo. The
[Lambdas-TFC-Example](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/tree/development/buildspecs)
repo demonstrates how the ones that live in the repo are configured:

- [`buildspecs/buildspec-build.yml`](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/blob/development/buildspecs/buildspec-build.yml)
  defines the configuration for the Build stage
- [`buildspecs/buildspec-build.sh`](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/blob/development/buildspecs/buildspec-build.sh)
  contains the code run in the Build stage. Many apps differ in how they are
  built, and this is the best place to put your custom build steps.
- [`buildspecs/buildspec-sonarqube.sh`](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/blob/development/buildspecs/buildspec-sonarqube.sh)
  contains the code used to run the SonarQube scanner on the source code and
  submit the report to SonarQube

Although you can write entire Bash scripts inside a YAML buildspec, we recommend
against this for reasons of maintainability. Bash is a notoriously complicated
language with many non-obvious pitfalls, and writing Bash inside YAML makes it
harder to discover subtle issues due to lack of syntax highlighting and lack of
[ShellCheck](https://www.shellcheck.net/) editor integration. Instead, write
your Bash script into a file that lives alongside your buildspec, and
[call it from the buildspec](https://github.com/PGEDigitalCatalyst/ECS-TFC-Example/blob/3e1b106e0fee4c0f7f44bef703a8a847ce84bed0/buildspecs/buildspec-build.yml#L8).

## Deploy mode

`var.buildspec_deploy` can be set to either `LAMBDA`, `ECS`, or `REPO`.

- [`LAMBDA`](codebuild_buildspec/buildspec_deploy_lambda.sh) is a preconfigured
  build stage that comes with this module to deploy your Lambda function.
- [`ECS`](codebuild_buildspec/buildspec_deploy_ecs.yml) is a preconfigured build
  stage that comes with this module to deploy your ECS instance.
- `REPO` indicates that you will bring your own buildspec, defined in your own
  repo at `buildspecs/buildspec-deploy.yml`. This allows you to define custom
  deploy behavior that is not provided by this module.
