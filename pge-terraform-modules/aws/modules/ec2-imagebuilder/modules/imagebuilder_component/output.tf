
output "component_names" {
  description = "List of the component names"
  value       = [for component in aws_imagebuilder_component.this : component.name]
}
output "component_arns" {
  description = "List of the component ARNs"
  value       = [for component in aws_imagebuilder_component.this : component.arn]

}