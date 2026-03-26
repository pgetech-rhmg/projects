output "queries_repo_commit" {
  value = local.queries_repo_commit
}

output "load_balancer_dns" {
  value = aws_lb.load_balancer.dns_name
}

output "route53_record" {
  value = aws_route53_record.service_dns.fqdn
}