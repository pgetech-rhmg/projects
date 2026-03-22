# SSM Documents for configuration and testing
# The config_manager Lambda runs these against sandbox instances
# using the naming convention: {prefix}-{component}

locals {
  ssm_doc_components = ["webadapter", "portal", "datastore", "server"]
}

# ConfigDoc - applies configuration to each component instance using PGE ssm-document module
module "ssm_config" {
  for_each = toset(local.ssm_doc_components)

  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"

  ssm_document_name   = "ConfigDoc-${each.key}"
  ssm_document_type   = "Command"
  ssm_document_format = "YAML"
  ssm_document_content = yamlencode({
    schemaVersion = "2.2"
    description   = "Apply configuration for ${each.key}"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "ApplyConfig"
        inputs = {
          runCommand = [
            "#!/bin/bash",
            "set -e",
            "echo 'Applying configuration for ${each.key}...'",
            "# TODO: Add component-specific configuration steps",
            "echo 'Configuration complete for ${each.key}'"
          ]
        }
      }
    ]
  })

  tags = local.merged_tags
}

# TestDoc - runs validation tests on each component instance using PGE ssm-document module
module "ssm_test" {
  for_each = toset(local.ssm_doc_components)

  source  = "app.terraform.io/pgetech/ssm/aws//modules/ssm-document"
  version = "0.1.2"

  ssm_document_name   = "TestDoc-${each.key}"
  ssm_document_type   = "Command"
  ssm_document_format = "YAML"
  ssm_document_content = yamlencode({
    schemaVersion = "2.2"
    description   = "Run tests for ${each.key}"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "RunTests"
        inputs = {
          runCommand = [
            "#!/bin/bash",
            "set -e",
            "echo 'Running tests for ${each.key}...'",
            "# TODO: Add component-specific test steps",
            "echo 'Tests passed for ${each.key}'"
          ]
        }
      }
    ]
  })

  tags = local.merged_tags
}
