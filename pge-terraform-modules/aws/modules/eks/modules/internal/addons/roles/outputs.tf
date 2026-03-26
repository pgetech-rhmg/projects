################################################################################
# IAM Role
################################################################################

output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = try(aws_iam_role.this[0].path, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# IAM Policy
# Note: The module is designed to create a single IAM role with a single policy;
# therefore, we only output one policy ARN, name, and ID (the first one that resolves)
################################################################################

output "iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value = try(

    aws_iam_policy.ebs_csi[0].arn,

    null,
  )
}

output "iam_policy_name" {
  description = "Name of IAM policy"
  value = try(

    aws_iam_policy.ebs_csi[0].name,

    null,
  )
}

output "iam_policy_id" {
  description = "The policy's ID"
  value = try(
    aws_iam_policy.ebs_csi[0].policy_id,

    null,
  )
}

################################################################################
# Pod Identity Association
################################################################################

output "associations" {
  description = "Map of Pod Identity associations created"
  value       = aws_eks_pod_identity_association.this
}

# EBS CSI KMS Key Outputs
output "ebs_csi_kms_key_arn" {
  description = "ARN of the KMS key for EBS CSI driver to encrypt EBS volumes it creates"
  value       = try(aws_kms_key.ebs_kms[0].arn, null)
}