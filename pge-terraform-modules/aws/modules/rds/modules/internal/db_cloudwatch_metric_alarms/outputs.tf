# cloudwatch metric alarms
output "cpu_utilization_too_high_metric_alarm_arn" {
  description = "The ARN of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = one(module.cpu_utilization_too_high[*].cloudwatch_metric_alarm_arn)
}
output "cpu_utilization_too_high_metric_alarm_id" {
  description = "The ID of the cpu_utilization_too_high cloudwatch metric alarm"
  value       = one(module.cpu_utilization_too_high[*].cloudwatch_metric_alarm_id)
}

output "cpu_credit_balance_too_low_alarm_arn" {
  description = "The ARN of the cpu_credit_balance_too_low cloudwatch metric alarm"
  value       = one(module.cpu_credit_balance_too_low[*].cloudwatch_metric_alarm_arn)
}
output "cpu_credit_balance_too_low_alarm_id" {
  description = "The ID of the cpu_credit_balance_too_low cloudwatch metric alarm"
  value       = one(module.cpu_credit_balance_too_low[*].cloudwatch_metric_alarm_id)
}

output "disk_queue_depth_too_high_metric_alarm_arn" {
  description = "The ARN of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = one(module.disk_queue_depth_too_high[*].cloudwatch_metric_alarm_arn)
}
output "disk_queue_depth_too_high_metric_alarm_id" {
  description = "The ID of the disk_queue_depth_too_high cloudwatch metric alarm"
  value       = one(module.disk_queue_depth_too_high[*].cloudwatch_metric_alarm_id)
}
output "disk_free_storage_space_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = one(module.disk_free_storage_space_too_low[*].cloudwatch_metric_alarm_arn)
}
output "disk_free_storage_space_too_low_metric_alarm_id" {
  description = "The ID of the disk_free_storage_space_too_low cloudwatch metric alarm"
  value       = one(module.disk_free_storage_space_too_low[*].cloudwatch_metric_alarm_id)
}
output "disk_burst_balance_too_low_metric_alarm_arn" {
  description = "The ARN of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = one(module.disk_burst_balance_too_low[*].cloudwatch_metric_alarm_arn)
}
output "disk_burst_balance_too_low_metric_alarm_id" {
  description = "The ID of the disk_burst_balance_too_low cloudwatch metric alarm"
  value       = one(module.disk_burst_balance_too_low[*].cloudwatch_metric_alarm_id)
}
output "memory_freeable_too_low_metric_alarm_arn" {
  description = "The ARN of the memory_freeable_too_low cloudwatch metric alarm"
  value       = one(module.memory_freeable_too_low[*].cloudwatch_metric_alarm_arn)
}
output "memory_freeable_too_low_metric_alarm_id" {
  description = "The ID of the memory_freeable_too_low cloudwatch metric alarm"
  value       = one(module.memory_freeable_too_low[*].cloudwatch_metric_alarm_id)
}
output "memory_swap_usage_too_high_metric_alarm_arn" {
  description = "The ARN of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = one(module.memory_swap_usage_too_high[*].cloudwatch_metric_alarm_arn)
}
output "memory_swap_usage_too_high_metric_alarm_id" {
  description = "The ID of the memory_swap_usage_too_high cloudwatch metric alarm"
  value       = one(module.memory_swap_usage_too_high[*].cloudwatch_metric_alarm_id)
}

output "anomalous_connection_count_metric_alarm_id" {
  description = "The ID of the anomalous_connection_count cloudwatch metric alarm"
  value       = one(aws_cloudwatch_metric_alarm.anomalous_connection_count[*].id)
}

output "anomalous_connection_count_metric_alarm_arn" {
  description = "The ARN of the anomalous_connection_count cloudwatch metric alarm"
  value       = one(aws_cloudwatch_metric_alarm.anomalous_connection_count[*].arn)
}
