terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3"
    }
  }
}

provider "aws" {
  region = var.region
}

# -----------------------------
# Fetch Portal admin password
# -----------------------------
data "aws_secretsmanager_secret_version" "portal_admin_password" {
  secret_id = var.portal_admin_password
}

locals {
  portal_admin_password = jsondecode(data.aws_secretsmanager_secret_version.portal_admin_password.secret_string).password
}

# -----------------------------
# Fetch Portal security question answer
# -----------------------------
data "aws_secretsmanager_secret_version" "portal_security_question_answer" {
  secret_id = var.portal_security_question_answer
}

locals {
  portal_security_question_answer = jsondecode(data.aws_secretsmanager_secret_version.portal_security_question_answer.secret_string).password
}

# -----------------------------
# Fetch Portal keystore file password
# -----------------------------
data "aws_secretsmanager_secret_version" "portal_keystore_file_password" {
  secret_id = var.portal_keystore_file_password
}

locals {
  portal_keystore_file_password = jsondecode(data.aws_secretsmanager_secret_version.portal_keystore_file_password.secret_string).password
}

# -----------------------------
# Fetch Hosting Server admin password
# -----------------------------
data "aws_secretsmanager_secret_version" "hosting_admin_password" {
  secret_id = var.hosting_admin_password
}

locals {
  hosting_admin_password = jsondecode(data.aws_secretsmanager_secret_version.hosting_admin_password.secret_string).password
}

# -----------------------------
# Fetch Hosting Server keystore file password
# -----------------------------
data "aws_secretsmanager_secret_version" "hosting_keystore_file_password" {
  secret_id = var.hosting_keystore_file_password
}

locals {
  hosting_keystore_file_password = jsondecode(data.aws_secretsmanager_secret_version.hosting_keystore_file_password.secret_string).password
}

# -----------------------------
# Fetch Go Server admin password
# -----------------------------
data "aws_secretsmanager_secret_version" "go_admin_password" {
  secret_id = var.go_admin_password
}

locals {
  go_admin_password = jsondecode(data.aws_secretsmanager_secret_version.go_admin_password.secret_string).password
}

# -----------------------------
# Fetch Go Server keystore file password
# -----------------------------
data "aws_secretsmanager_secret_version" "go_keystore_file_password" {
  secret_id = var.go_keystore_file_password
}

locals {
  go_keystore_file_password = jsondecode(data.aws_secretsmanager_secret_version.go_keystore_file_password.secret_string).password
}

# -----------------------------
# Fetch Tomcat keystore password
# -----------------------------
data "aws_secretsmanager_secret_version" "tomcat_keystore_password" {
  secret_id = var.tomcat_keystore_password
}

locals {
  tomcat_keystore_password = jsondecode(data.aws_secretsmanager_secret_version.tomcat_keystore_password.secret_string).password
}