# AWS KMS Terraform module
 Terraform base module for deploying KMS in Amazon Web Services.

 These features of KMS configurations are supported in this module example.
 - Customer managed key and alias creation with default pge kms policy.  (`module/kms/kms_pge_compliance_policy.json`)
 - If `policy` variable is not defined by user, module will automatically assume default pge kms policy (`module/kms/kms_pge_compliance_policy.json`). If defined, it will append user defined policy with pge default policies.
