output "nlb_dns_name_rw" {
  value = aws_lb.nlb_readwrite.dns_name
}

output "nlb_dns_name_ro" {
  value = aws_lb.nlb_readonly.dns_name
}
