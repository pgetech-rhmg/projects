/*
* # AWS Amplify with usage example
* Terraform module which creates SAF2.0 Amplify App resource in AWS.
*
* #### Pre-requisites
* 1. Create a github repository under pgetech organization to host the
*    application code.
* 2. Push the application code to the main branch of the github repository
*    created in step 1.
* 3. Create environment specific branches in the github repository.
*    We are considering DEV, TEST and QA environments for the example
*    and hence create github branches DEV, TEST, and QA from main branch.
* 4. Secrets manager for storing personal access token and basic auth
*    credentials must be existing to run this example.
*
* #### AWS Amplify usage example
* 1. Provide the above created github repository name for
*    argument **github_repository_name**
* 2. Setup IAM role to be used as a service role to have permission
*    to create and modify amplify resources.
* 3. Module amplify branch creates Main branch (prod),
*    DEV, TEST, and QA (non-prod) branches.
* 4. Respective environment backend and webhook are configured using
*    amplify_backend_environment module and amplify_webhook module.
* 5. Module amplify_domain_association is used to provide domain for
*    the example. A domain name is provided in format ending with
*    ss.pge.com (main.ss.pge.com) for production and nonprod.pge.com
*    (dev.nonprod.pge.com, test.nonprod.pge.com and qa.nonprod.pge.com)
*    for non production enviroment. These are not real domain names
*    hence the argument **wait_for_verification** is set to false so
*    that it will not wait for verification on domain to complete.
* 6. After apply amplify resource is created and build is in queue for
*    respective branches.  Manually run these builds in console, this
*    will create stack and S3 bucket. Once the build and deploy is
*    completed, amplify app endpoint can be accessed using basic auth
*    credentials provided in example.
* 7. Once terraform destroy is run, all the resources are destroyed that
*    are created from the terraform code but stack and S3 bucket created
*    when build is run, needs to be destroyed manually.
*
*/
#
# Filename    : modules/amplify/examples/amplify/main.tf
# Date        : 22 September 2022
# Author      : TCS

# Description : The Terraform usage example creates aws amplify app in AWS.

locals {
  name = "${var.name}-${random_string.name.result}"
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

# Random String

resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

# Amplify App
module "amplify_app" {
  source = "../.."

  name                          = local.name
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  custom_rule                   = var.custom_rule

  secretsmanager_github_access_token_secret_name = var.secretsmanager_github_access_token_secret_name
  secretsmanager_basic_auth_cred_secret_name     = var.secretsmanager_basic_auth_cred_secret_name

  github_repository_name      = var.github_repository_name
  environment_variables       = var.environment_variables
  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_auto_branch_creation = var.enable_auto_branch_creation

  auto_branch_creation_config = ({
    build_spec                    = var.build_spec
    enable_auto_build             = var.enable_auto_build
    enable_performance_mode       = var.enable_performance_mode
    enable_pull_request_preview   = var.enable_pull_request_preview
    environment_variables         = var.auto_branch_environment_variables
    framework                     = var.auto_branch_framework
    pull_request_environment_name = var.pull_request_environment_name
    stage                         = var.stage
  })

  iam_service_role_arn = module.amplify_iam_role.arn
  tags                 = merge(module.tags.tags, var.optional_tags)
}

#IAM Role for Amplify
module "amplify_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}

# Main Branch and Main Backend Environment

module "amplify_branch_main" {
  source = "../../modules/amplify_branch"

  app_id                  = module.amplify_app.id
  branch_name             = var.main_branch_name
  stage                   = var.main_stage
  framework               = var.framework
  backend_environment_arn = module.amplify_backend_environment_main.arn
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "amplify_backend_environment_main" {
  source = "../../modules/amplify_backend_environment"

  app_id           = module.amplify_app.id
  environment_name = var.main_branch_name
}

# Dev Branch and Dev Backend Environment

module "amplify_branch_dev" {
  source = "../../modules/amplify_branch"

  app_id                  = module.amplify_app.id
  branch_name             = var.dev_branch_name
  stage                   = var.dev_stage
  framework               = var.framework
  backend_environment_arn = module.amplify_backend_environment_dev.arn
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "amplify_backend_environment_dev" {
  source = "../../modules/amplify_backend_environment"

  app_id           = module.amplify_app.id
  environment_name = var.dev_branch_name
}

# QA Branch and QA Backend Environment

module "amplify_branch_qa" {
  source = "../../modules/amplify_branch"

  app_id                  = module.amplify_app.id
  branch_name             = var.qa_branch_name
  stage                   = var.qa_stage
  framework               = var.framework
  backend_environment_arn = module.amplify_backend_environment_qa.arn
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "amplify_backend_environment_qa" {
  source = "../../modules/amplify_backend_environment"

  app_id           = module.amplify_app.id
  environment_name = var.qa_branch_name
}

# Test Branch and Test Backend Environment

module "amplify_branch_test" {
  source = "../../modules/amplify_branch"

  app_id                  = module.amplify_app.id
  branch_name             = var.test_branch_name
  stage                   = var.test_stage
  framework               = var.framework
  backend_environment_arn = module.amplify_backend_environment_test.arn
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "amplify_backend_environment_test" {
  source = "../../modules/amplify_backend_environment"

  app_id           = module.amplify_app.id
  environment_name = var.test_branch_name
}

# Webhook - main

module "amplify_webhook_main" {
  source = "../../modules/amplify_webhook"

  app_id      = module.amplify_app.id
  branch_name = var.main_branch_name
  depends_on = [
    module.amplify_branch_main
  ]
}

# Webhook - dev

module "amplify_webhook_dev" {
  source = "../../modules/amplify_webhook"

  app_id      = module.amplify_app.id
  branch_name = var.dev_branch_name
  depends_on = [
    module.amplify_branch_dev
  ]
}

# Webhook - qa

module "amplify_webhook_qa" {
  source = "../../modules/amplify_webhook"

  app_id      = module.amplify_app.id
  branch_name = var.qa_branch_name
  depends_on = [
    module.amplify_branch_qa
  ]
}

# Webhook - test

module "amplify_webhook_test" {
  source = "../../modules/amplify_webhook"

  app_id      = module.amplify_app.id
  branch_name = var.test_branch_name
  depends_on = [
    module.amplify_branch_test
  ]
}

#Time sleep is used to wait for 5 mins after branch is created
resource "time_sleep" "wait1_5min" {
  depends_on = [module.amplify_branch_main]

  create_duration = "5m"
}

resource "time_sleep" "wait2_5min" {
  depends_on = [module.amplify_branch_dev, module.amplify_branch_qa, module.amplify_branch_test]

  create_duration = "5m"
}

# Domain Association - prod

module "domain_association_prod" {
  source = "../../modules/amplify_domain_association"

  app_id      = module.amplify_app.id
  domain_name = var.domain_name_prod

  sub_domain = [{
    branch_name = var.main_branch_name
    prefix      = var.sub_domain_prefix_main
  }]

  wait_for_verification = var.amplify_domain_wait_for_verification

  depends_on = [time_sleep.wait1_5min]

}

# Domain Association - Non-prod

module "domain_association_non_prod" {
  source = "../../modules/amplify_domain_association"

  app_id      = module.amplify_app.id
  domain_name = var.domain_name_non_prod

  sub_domain = [{
    branch_name = var.dev_branch_name
    prefix      = var.sub_domain_prefix_dev
    },
    {
      branch_name = var.qa_branch_name
      prefix      = var.sub_domain_prefix_qa
    },
    {
      branch_name = var.test_branch_name
      prefix      = var.sub_domain_prefix_test
  }]

  wait_for_verification = var.amplify_domain_wait_for_verification

  depends_on = [time_sleep.wait2_5min]

}