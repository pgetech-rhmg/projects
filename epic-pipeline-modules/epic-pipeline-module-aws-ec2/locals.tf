############################################
# Locals
############################################

locals {
  resolved_role_name = var.iam.create_instance_profile ? aws_iam_role.this[0].name : var.iam.role_name
}