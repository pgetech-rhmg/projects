# Outputs for glue_job

output "glue_job_arn" {
  description = "Amazon Resource Name (ARN) of Glue Job"
  value       = aws_glue_job.glue_job.arn
}

output "glue_job_id" {
  description = "Job name"
  value       = aws_glue_job.glue_job.id
}

output "glue_job_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_glue_job.glue_job.tags_all
}

output "aws_glue_job" {
  description = "A map of aws_glue_job object."
  value       = aws_glue_job.glue_job
}