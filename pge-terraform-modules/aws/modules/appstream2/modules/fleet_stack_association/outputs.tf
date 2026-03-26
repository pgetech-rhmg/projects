output "id_fleet_stack" {
  description = "Unique ID of the appstream stack fleet association, composed of the fleet_name and stack_name separated by a slash (/)."
  value       = aws_appstream_fleet_stack_association.fleet_stack.id
}


output "id_fleet_all" {
  description = "Map of all id_fleet attributes"
  value       = aws_appstream_fleet_stack_association.fleet_stack
}