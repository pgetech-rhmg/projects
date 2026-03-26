output "id" {
  description = "Unique identifier (ID) of the appstream fleet."
  value       = aws_appstream_fleet.fleet.id
}

output "arn" {
  description = " ARN of the appstream fleet."
  value       = aws_appstream_fleet.fleet.arn
}

output "state" {
  description = "State of the fleet. Can be STARTING, RUNNING, STOPPING or STOPPED"
  value       = aws_appstream_fleet.fleet.state
}

output "created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the fleet was created."
  value       = aws_appstream_fleet.fleet.created_time
}

output "compute_capacity" {
  description = "Describes the capacity status for a fleet."
  value       = aws_appstream_fleet.fleet.compute_capacity
}

output "all" {
  description = "Map of all appstream fleet attributes"
  value       = aws_appstream_fleet.fleet
}