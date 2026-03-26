output "codepipeline_id" {
  value       = aws_codepipeline.codepipeline.id
  description = "The codepipeline ID"
}
output "codepipeline_arn" {
  value       = aws_codepipeline.codepipeline.arn
  description = "The codepipeline ARN"
}

output "codepipeline_all" {
  description = "Map of Codepipeline object"
  value       = aws_codepipeline.codepipeline
}