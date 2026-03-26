#outputs for MRAD Sumo module

output "sumo_firehose_http_endpoint_url" {
  value = data.aws_ssm_parameter.sumo_firehose_http_endpoint_url.value
}
