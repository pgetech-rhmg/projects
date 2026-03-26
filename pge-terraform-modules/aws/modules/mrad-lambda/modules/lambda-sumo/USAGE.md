# mrad-lambda-sumo v1

mrad-lambda-sumo creates an instance of
[AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) to run
your application code. It also configures
[AWS API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
to serve HTTP requests and submits log messages to
[Sumo Logic](https://wiki.comp.pge.com/pages/viewpage.action?pageId=55837383).

# Installation

_See a full working example:_

- [Lambdas-TFC-Example](https://github.com/PGEDigitalCatalyst/Lambdas-TFC-Example/blob/development/terraform/code/main.tf):
  deploy a Lambda function using this CodePipeline module

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
    QA   = "main" # or "master"
    Prod = "production"
  }[local.aws_account]

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

module "lambda" {
  source  = "app.terraform.io/pgetech/mrad-lambda/aws//modules/lambda-sumo"
  version = "~> 1.0"
  tags    = local.tags

  archive_path = "../../Lambda"
  aws_account  = local.aws_account
  aws_region   = "us-west-2"
  aws_role     = var.aws_role
  kms_role     = "MRAD_Ops"
  lambda_name  = local.repository_name
  service      = ["lambda.amazonaws.com"]

  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH

  layers = [
    "arn:aws:lambda:us-west-2:${data.aws_caller_identity.current.account_id}:layer:cloud-utilities:${var.lambda_layer_versions[local.aws_account].cloud_utilities}"
  ]

  envvars = {
    "NODE_ENV"            = local.aws_account == "Prod" ? "production" : lower(local.aws_account),
    "TERRAFORM_WORKSPACE" = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  }
}

# CodePipeline automatically deploys from your GitHub branch to your Lambda function
module "pipeline" {
  source  = "app.terraform.io/pgetech/mrad-codepipeline/aws"
  version = "~> 1.0"
  tags    = local.tags

  buildspec_deploy = "LAMBDA"
  ci_enable        = !contains(["Prod", "QA"], local.aws_account) # CI is not currently supported in QA/Prod due to Sentinel policy issues
  project_name     = local.repository_name
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

Configure the MRAD Lambda module by setting its variables in your Terraform file
([documentation](variables.tf)), committing your values to your branch, and
pushing to GitHub.

Your Lambda code lives in your repo under `Lambda/`:

```
Lambda
├── package-lock.json
├── package.json
└── src
    └── index.js
```

The Lambda handler function is an export in `src/index.js` named `handler`:

```js
// src/index.js
exports.handler = () => {
  console.log("Lambda has successfully executed.");
  return "OK";
};
```

You can use the following Terraform variables to reconfigure the module:

- `archive_path`: Points to the directory which contains `package.json` and your
  app's source code.
- `handler`: Points to the entrypoint for your Lambda function code. Defaults to
  `src/index.handler`. If you want to use a function named `main` in
  `src/entrypoint.js`, use `src/entrypoint.main`.

## Warmer Configuration

The Lambda concurrency warmer is enabled by default to ensure provisioned concurrency is available in production environments. The warmer is automatically disabled in Dev environments.

### Disabling the Warmer

If you need to disable the warmer (e.g., during initial deployment in QA/Prod or for specific use cases), set:

```terraform
module "my-lambda" {
  ...
  disable_warmer = true
  ...
}
```

When `disable_warmer = true`, no warmer S3 bucket or provisioned concurrency configuration will be created. The S3 bucket logging configuration is derived automatically from the Lambda name, environment, and branch—no manual bucket configuration required.

### Warmer Bucket Naming

When the warmer is enabled, it uses an internal S3 bucket for artifacts named:
```
${lambda_name}-warmer-${aws_account}-${branch}
```

This bucket name is computed automatically and does not require any module input.
