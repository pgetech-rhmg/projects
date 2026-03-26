locals {
  account_num     = data.aws_caller_identity.current.account_id
  envname         = local.account_id_to_envname_table[local.account_num]
  project_name    = "Engage-DB-Scheduler"
  subnet_id       = local.subnet_qualifier[local.envname]
  short_name      = "dbsched"
  s3_bucket       = "webcore-engage-${lower(var.suffix)}-lambdas"
  s3_key          = "Engage-DB-Scheduler.zip"
  sumo_layer_arn  = "arn:aws:lambda:us-west-2:663229565520:layer:sumologic-otel-lambda-nodejs-x86_64-v2-0-0:1"
  


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

  run_on_friday = {
    name                = "dbsched_run_on_friday"
    # 7pm PST is 2am UTC next day
    description         = "Schedule the dbsched Lambda at 7pm Friday evening (PST)"
    schedule_expression = "cron(11 2 ? * SAT *)"
  }

  run_on_monday = {
    name                = "dbsched_run_on_monday"
    description         = "Schedule the dbsched Lambda at 6pm Sunday evening (PST)"
    schedule_expression = "cron(0 2 ? * MON *)"
  }
}
