# mrad-lambda-sumo v1

mrad-lambda-sumo creates an instance of
[AWS ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
to run your application code. It also configures an
[AWS ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
to serve HTTP requests and submits log messages to
[Sumo Logic](https://wiki.comp.pge.com/pages/viewpage.action?pageId=55837383).

# Installation

_See a full working example:_

- [ECS-TFC-Example](https://github.com/PGEDigitalCatalyst/ECS-TFC-Example/blob/development/terraform/code/main.tf):
  deploy an ECS instance using this CodePipeline module

Add the module to your repo along with its supporting code:

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = "~> 2.1"
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

# Authenticate to Sumo Logic for logging
data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}
provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

# https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment
variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {}

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
    QA   = "main"
    Prod = "production"
  }[local.aws_account]

  # If true, this is a production environment
  prod = contains(["Prod", "QA"], local.aws_account)

  # The base domain to use for the DNS entry for this app
  domain = local.prod ? "dc.pge.com" : "nonprod.pge.com"

  # The name of this GitHub repository. Case-sensitive.
  repository_name = "my-repository"

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

module "ecs" {
  source  = "app.terraform.io/pgetech/mrad-ecs/aws"
  version = "~> 1.0"
  tags    = module.tags.tags

  providers = {
    aws          = aws
    aws.r53      = aws.r53
    aws.ccoe_dns = aws.r53
    sumologic    = sumologic
  }

  aws_region                 = "us-west-2"
  aws_account                = local.aws_account
  aws_role                   = var.aws_role
  additional_task_iam_policy = data.aws_iam_policy_document.task_iam_policy.json

  project_name = local.repository_name
  branch       = local.branch
  domain       = local.domain

  lb                = true
  health_check_path = var.health_check_path
  desired_count     = var.instance_count[local.aws_account]
}

module "pipeline" {
  source  = "app.terraform.io/pgetech/mrad-codepipeline/aws"
  version = "~> 1.0"
  tags    = module.tags.tags

  buildspec_deploy        = "ECS"
  ci_enable               = !local.prod # CI is not supported in qa/prod yet due to Sentinel policy issues
  privileged_deploy_stage = true # Required to build and push Docker images
  project_name            = local.repository_name
  branch                  = local.branch
  aws_account             = local.aws_account
  aws_role                = var.aws_role
  github_secret           = local.github_token_secret_name
  codebuild_image         = var.codebuild_image
  ecr_repo_urls           = module.ecs.ecr_repo_urls
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

Configure the MRAD ECS module by setting its variables in your Terraform file
([documentation](variables.tf)), committing your values to your branch, and
pushing to GitHub.

Typically, your application code lives in your repo in a structure like this:

```
Dockerfile.tmpl
package-lock.json
package.json
src
└── index.js (and the rest of your app code)
terraform
└── code
    └── ...your Terraform code lives here...
```

You can use the following Terraform variables to reconfigure the module:

- `entry_point`: Points to the entrypoint inside your container to run when
  booting the ECS instance. Defaults to `bash run.sh`.
- `port`: The port on which this container serves HTTP requests.
- `health_check_path`: The path ECS uses to make HTTP requests into the
  container to determine if the container is online and ready to serve requests.
  Defaults to `/`.

## Dockerfile

ECS runs container images, and we use Docker to build your container image and
push it to
[AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html).
MRAD CodePipeline builds your container in the
[Wiz stage](../mrad-codepipeline/codebuild_buildspec/buildspec_wizscan.yml),
which depends on the `Dockerfile.tmpl` existing in your repo.

`Dockerfile.tmpl` is the Dockerfile template that specifies how your app is
packaged for production deployment. We build the real Dockerfile from this
template by using [envsubst](https://linux.die.net/man/1/envsubst) to
interpolate values such as `${DOCKER_NODE_BASEIMAGE}` from this stage's
environment variables.

We recommend you use a
[dev script](https://github.com/PGEDigitalCatalyst/ECS-TFC-Example/blob/3e1b106e0fee4c0f7f44bef703a8a847ce84bed0/bin/run-image)
to test your image locally before pushing to CodePipeline, so you can discover
issues locally before you discover them when the build fails.

After your container is successfully built, the stage scans it with Wiz,
pushes it to ECR, and configure ECS to run the container from that source.
