output "canary_id" {
  description = "ID of the Canary"
  value       = module.canary.aws_synthetics_canary.id
}

output "canary_arn" {
  description = "arn of the canary"
  value       = module.canary.aws_synthetics_canary.arn

}

output "canary_status" {
  description = "status of the canary"
  value       = module.canary.aws_synthetics_canary.status

}

output "canary_tags" {
  description = "tags of the canary"
  value       = module.canary.aws_synthetics_canary.tags_all

}

