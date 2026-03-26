locals {
  account_num     = data.aws_caller_identity.current.account_id
  node_env        = local.account_id_to_nodeenv_table[local.account_num]
  envname         = local.account_id_to_envname_table[local.account_num]
  principal_orgid = "o-7vgpdbu22o"
  project_name    = "Engage-PTT-Second-Pass-Update"
  subnet_id       = local.subnet_qualifier[local.envname]
  kms_role        = "Engage_Ops"
  aws_role        = aws_iam_role.lambda_role.name
  short_name      = "pttup"
  s3_bucket       = "webcore-engage-${lower(local.envname)}-lambdas"
  s3_key          = "Ptt-Pending-Follow-Up-Update-Lambda.zip"
  sumo_layer_arn  = "arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1"

  account_id_to_nodeenv_table = {
    "990878119577" = "dev",
    "471817339124" = "qa",
    "712640766496" = "production"
  }

  account_id_to_envname_table = {
    "990878119577" = "Dev",
    "471817339124" = "QA",
    "712640766496" = "Prod"
  }

  subnet_qualifier = {
    Dev  = "Dev-2",
    QA   = "QA",
    Prod = "Prod"
  }

  sumologic_endpoint = local.sumologic_endpoints[local.envname]

  sumologic_endpoints = {
    "Dev" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "QA" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "Prod" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2VAhF7q7H7TSCmlmurlwUW3mEkTEtEx_yoctcvkibT3DKaAERVs7IcsHiPyGgZWT_bYcxDdd026M42AIJopKFgcUAGCKEo901njSMV-TsIYw=="
  }
}
