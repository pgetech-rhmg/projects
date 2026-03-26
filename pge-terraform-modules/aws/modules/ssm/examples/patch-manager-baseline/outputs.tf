output "patch_baseline_arn" {
  description = "SSM Patch Manager patch baseline ARN"
  value       = module.ssm-patch-manager-baseline.arn
}

output "patch_baseline_id" {
  description = "SSM Patch Manager patch baseline ID"
  value       = module.ssm-patch-manager-baseline.id
}

output "patchgroup_id" {
  description = "SSM Patch Manager patch group ID"
  value       = module.ssm-patch-manager-baseline[*].patchgroup_id
}
