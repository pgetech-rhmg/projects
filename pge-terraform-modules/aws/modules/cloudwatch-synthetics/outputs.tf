output "aws_synthetics_canary" {
  description = "A map of aws synthetic canary resource"
  value       = aws_synthetics_canary.canary_api_calls
}