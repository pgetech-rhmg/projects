locals {
  account_num     = data.aws_caller_identity.current.account_id
  node_env        = local.account_id_to_nodeenv_table[local.account_num]
  envname         = local.account_id_to_envname_table[local.account_num]
  subnet_id       = local.subnet_qualifier[local.envname]
  short_name      = "gisseed"
  region          = data.aws_region.current.name
  s3_bucket       = "webcore-engage-${lower(local.envname)}-lambdas"
  s3_key          = "Engage-WSG-Seed.zip"
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

  gis_seed_gis_endpoint = local.gis_endpoints[local.envname]

  gis_endpoints = {
    "Dev"  = "https://a066nujazc-vpce-004df99e88b0b56a6.execute-api.us-west-2.amazonaws.com/gmv/gmv/updatestatus",
    "QA"   = "https://a066nujazc-vpce-004df99e88b0b56a6.execute-api.us-west-2.amazonaws.com/gmv/gmv/updatestatus",
    "Prod" = "https://waj243n4i8-vpce-0e24dbb4ba103df1a.execute-api.us-west-2.amazonaws.com/gmv/gmv/updatestatus"
  }

  sumologic_endpoint = local.sumologic_endpoints[local.envname]

  sumologic_endpoints = {
    "Dev" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "QA" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "Prod" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2VAhF7q7H7TSCmlmurlwUW3mEkTEtEx_yoctcvkibT3DKaAERVs7IcsHiPyGgZWT_bYcxDdd026M42AIJopKFgcUAGCKEo901njSMV-TsIYw=="
  }

  # This policy is added on to the default policy that the KMS module creates
  kms_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Allow ${aws_iam_role.lambda_role.name} Lambda to use CMK",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.account_num}:role/${aws_iam_role.lambda_role.name}"
        },
        Action = [
          "kms:*"
        ],
        Resource = "*"
      }
    ]
  })
}
