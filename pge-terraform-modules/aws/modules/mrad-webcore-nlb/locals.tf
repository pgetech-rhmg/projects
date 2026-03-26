locals {
  account_num        = data.aws_caller_identity.current.account_id
  envname            = local.account_id_to_envname_table[local.account_num]
  subnet_id          = local.subnet_qualifier[local.envname]
  sumologic_endpoint = local.sumologic_endpoints[local.envname]
  subdomain          = local.account_num_to_subdomain[local.account_num]
  nlb_ro_dns_name    = "${var.prefix}-${var.suffix}-ro.${local.subdomain}"
  nlb_rw_dns_name    = "${var.prefix}-${var.suffix}-rw.${local.subdomain}"

  account_num_to_subdomain = {
    "990878119577" = "nonprod.pge.com"
    "471817339124" = "dc.pge.com"
    "712640766496" = "dc.pge.com"
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

  sumologic_endpoints = {
    "Dev"  = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "QA"   = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2JT06PBNlbkCRG7Oa1XbeVQBQGAhJtvAnAPZfnYYOOvLey9rvQqT47SVBWA2dx7ZFjjlGKWqITWGy9jEVTHXHmvXo_-D1s8Cbo74Mt0ZB-cQ=="
    "Prod" = "https://endpoint3.collection.us2.sumologic.com/receiver/v1/trace/ZaVnC4dhaV2VAhF7q7H7TSCmlmurlwUW3mEkTEtEx_yoctcvkibT3DKaAERVs7IcsHiPyGgZWT_bYcxDdd026M42AIJopKFgcUAGCKEo901njSMV-TsIYw=="
  }

  # leaving this here for reference, but not currently used
  ccoe_dns_zones = {
    nonprod_private = "Z1PO7XO596QKJW"        # nonprod.pge.com
    nonprod_public  = "Z184J8PCMR81S"
    ss_private      = "Z11LPAP1YPL6IP"        # ss.pge.com
    ss_public       = "Z1L62V2HVS0BPZ"
    dc_private      = "Z33OQN3FB26IXH"        # dc.pge.com
    dc_public       = "Z2ONI094CU6J13"
    digcat_private  = "Z0967429WLFI8DLBONVR"  # digitalcatalyst.pge.com
    digcat_public   = "Z2LCMGY80QSDZ7"
  }
}
