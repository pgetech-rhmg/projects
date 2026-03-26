#Outputs for record
output "name" {
  description = "The name of the record."
  value = {
    for index, value in aws_route53_record.records : index => value.name
  }
}

output "fqdn" {
  description = "FQDN built using the zone domain and name."
  value = {
    for index, value in aws_route53_record.records : index => value.fqdn
  }
}