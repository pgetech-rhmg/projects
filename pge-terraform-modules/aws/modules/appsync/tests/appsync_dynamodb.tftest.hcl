run "appsync_dynamodb" {
  command = apply

  module {
    source = "./examples/appsync_dynamodb"
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
  authentication_type                                    = "AWS_IAM"
  name                                                   = "test_appsync"
  xray_enabled                                           = true
  client_id                                              = "client_id_test"
  issuer                                                 = "https://itiampingdev.cloud.pge.com"
  issuer2                                                = "https://itiamping.cloud.pge.com"
  additional_authentication_provider_authentication_type = "OPENID_CONNECT"
  web_acl_arn                                            = "arn:aws:wafv2:us-west-2:056672152820:regional/webacl/web_acl_for_appsync_testing/0a12b387-75fb-4a5a-82ee-5a7f36f5cdf8"
  domain_role_service                                    = ["appsync.amazonaws.com", "lambda.amazonaws.com"]
  policy_arns                                            = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess"]
  type                                                   = "AMAZON_DYNAMODB"
  versioned                                              = true
  hash_key                                               = "UserId"
  range_key                                              = "title"
  hash_range_key_attributes = [
    {
      name = "UserId"
      type = "S"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]
  local_secondary_indexes = [
    {
      name               = "TitleIndex"
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
      non_key_attributes = ["UserId"]
    }
  ]
  ttl_enabled               = true
  ttl_attribute_name        = "ttl_dynamo_table"
  stream_enabled            = true
  stream_view_type          = "NEW_AND_OLD_IMAGES"
  kms_description           = "CMK for encrypting dynamodb"
  domain_name               = "appsync-ccoe.tfappsync01.nonprod.pge.com"
  certificate_arn           = "arn:aws:acm:us-east-1:056672152820:certificate/cf32fd42-c2a7-4594-91bf-2dcf3d6bbbc0"
  request_mapping_template  = <<EOF
{
    "version": "2018-05-29",
    "method": "GET",
    "resourcePath": "/",
    "params":{
        "headers": $utils.http.copyheaders($ctx.request.headers)
    }
}
EOF
  response_mapping_template = <<EOF
    $ctx.result.body
    $utils.appendError($ctx.result.body, $ctx.result.statusCode)
EOF
  conflict_detection        = "VERSION"
  conflict_handler          = "LAMBDA"
  resolver_type             = "Query"
  field                     = "singlePost"
  request_template          = <<EOF
{
    "version": "2018-05-29",
    "method": "GET",
    "resourcePath": "/",
    "params":{
        "headers": $utils.http.copyheaders($ctx.request.headers)
    }
}
EOF
  response_template         = <<EOF
    $ctx.result.body
    $utils.appendError($ctx.result.body, $ctx.result.statusCode)
EOF
  caching_keys              = ["$context.identity.sub", "$context.arguments.id", ]
  ttl                       = 60
  kind                      = "UNIT"
  description               = "testing aws lambda"
  runtime                   = "python3.9"
  handler                   = "lambda_function.lambda_handler"
  content                   = <<EOF
def hello_world(event_data, lambda_config):
    print ("hello world")
EOF
  filename                  = "index.py"
  ssm_parameter_subnet_id1  = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2  = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3  = "/vpc/2/privatesubnet3/id"
  ssm_parameter_vpc_id      = "/vpc/id"
}
