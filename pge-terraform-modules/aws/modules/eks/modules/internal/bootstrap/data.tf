data "aws_secretsmanager_secret_version" "wiz-secret" {
  secret_id = "shared-eks-wiz-creds"
}

data "aws_secretsmanager_secret_version" "wiz-eks" {
  secret_id = "shared-eks-wiz-creds"
}

data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.encryption_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo encrypting codepipeline and codebuild artifacts with kms key arn/encryption id is mandatory for the DataClassfication type; exit 1"]
}
