run "appsync_lambda" {
  command = apply

  module {
    source = "./examples/appsync_lambda"
  }
}

variables {
  account_num                                            = "056672152820"
  aws_region                                             = "us-west-2"
  aws_role                                               = "CloudAdmin"
  AppID                                                  = "1001"
  Environment                                            = "Dev"
  DataClassification                                     = "Internal"
  CRIS                                                   = "Low"
  Notify                                                 = ["abc1@pge.com", "def2@pge.com"]
  Owner                                                  = ["abc1", "def2", "ghi3"]
  Compliance                                             = ["None"]
  Order                                                  = 8115205
  optional_tags                                          = { service = "appsync" }
  authentication_type                                    = "OPENID_CONNECT"
  name                                                   = "test_appsync"
  xray_enabled                                           = true
  visibility                                             = "PRIVATE"
  client_id                                              = "client_id_test"
  issuer                                                 = "https://itiampingdev.cloud.pge.com"
  additional_authentication_provider_authentication_type = "AWS_IAM"
  web_acl_arn                                            = "arn:aws:wafv2:us-west-2:056672152820:regional/webacl/web_acl_for_appsync_testing/0a12b387-75fb-4a5a-82ee-5a7f36f5cdf8"
  domain_role_service                                    = ["appsync.amazonaws.com", "lambda.amazonaws.com"]
  type                                                   = "AWS_LAMBDA"
  domain_name                                            = "appsync.tfappsync01.nonprod.pge.com"
  certificate_arn                                        = "arn:aws:acm:us-east-1:056672152820:certificate/cf32fd42-c2a7-4594-91bf-2dcf3d6bbbc0"
  max_batch_size                                         = 5
  request_mapping_template                               = <<EOF
{
    "version": "2018-05-29",
    "method": "GET",
    "resourcePath": "/",
    "params":{
        "headers": $utils.http.copyheaders($ctx.request.headers)
    }
}
EOF
  response_mapping_template                              = <<EOF
    $ctx.result.body
    $utils.appendError($ctx.result.body, $ctx.result.statusCode)
EOF
  description                                            = "testing aws lambda"
  runtime                                                = "python3.9"
  handler                                                = "lambda_function.lambda_handler"
  content                                                = <<EOF
def hello_world(event_data, lambda_config):
    print ("hello world")
EOF
  filename                                               = "index.py"
  ssm_parameter_subnet_id1                               = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                               = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                               = "/vpc/2/privatesubnet3/id"
  ssm_parameter_vpc_id                                   = "/vpc/id"
  resolver_type                                          = "Mutation"
  field                                                  = "putPost"
  request_template                                       = "{}"
  kind                                                   = "PIPELINE"
  response_template                                      = "$util.toJson($ctx.result)"
}
