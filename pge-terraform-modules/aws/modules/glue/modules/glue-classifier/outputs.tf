# Outputs for glue_classifier

output "classifier_id" {
  description = "Name of the classifier."
  value       = aws_glue_classifier.glue_classifier.id
}

output "aws_glue_classifier" {
  description = "The map of aws_glue_classifier object."
  value       = aws_glue_classifier.glue_classifier
}