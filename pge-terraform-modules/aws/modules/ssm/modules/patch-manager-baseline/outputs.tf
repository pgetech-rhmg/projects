output "patch_baseline_all" {
  value       = aws_ssm_patch_baseline.baseline
  description = "Map of all Patch baseline object"
}

output "arn" {
  description = "SSM Patch Manager patch baseline ARN"
  value       = aws_ssm_patch_baseline.baseline.arn
}

output "id" {
  description = "SSM Patch Manager patch baseline ID"
  value       = aws_ssm_patch_baseline.baseline.id
}

output "patchgroup_id" {
  description = "SSM Patch Manager patch group ID"
  value       = aws_ssm_patch_group.patchgroup[*].id
}
