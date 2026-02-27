output "validation_record_fqdns" {
  description = "The FQDNs of the CNAME validation records"
  value       = [for record in aws_route53_record.cname : record.fqdn]
}
