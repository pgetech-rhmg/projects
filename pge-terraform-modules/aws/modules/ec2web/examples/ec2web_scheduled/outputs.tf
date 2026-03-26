output "fqdn" {
  description = "FQDN built using the zone domain and name."
  value       = module.ec2-asg-alb.url
}

output "schedule_names" {
  description = "Names of the schedules created for the ASG"
  value       = module.scheduler.schedules
}