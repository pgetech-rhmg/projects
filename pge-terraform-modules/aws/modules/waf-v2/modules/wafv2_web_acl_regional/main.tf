/*
 * # AWS WAF Web ACL Regional module
 * Terraform module which creates SAF2.0 WAF Web ACL Regional in AWS
*/

#
#  Filename    : aws/modules/waf-v2/wafv2_web_acl_regional/main.tf
#  Date        : 2 February 2022
#  Author      : TCS
#  Description : WAF terraform module to create a waf v2 webacl regional.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : WAF Web ACL
# Description : This terraform module creates a waf web acl regional.

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_wafv2_web_acl" "wafv2-web-acl" {

  name        = var.webacl_name
  description = coalesce(var.webacl_description, format("%s waf web acl description - Managed by Terraform", var.webacl_name))
  scope       = "REGIONAL"

  # Default web acl action for requests that don't match any rules.
  default_action {

    dynamic "allow" {
      for_each = var.request_default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.request_default_action == "block" ? [1] : []
      content {}
    }
  }
  # custom_response_body is an optional dynamic block with object type variable, this block will execute only if the user configures the block.
  dynamic "custom_response_body" {
    for_each = var.custom_response_body
    content {
      key          = custom_response_body.value.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    sampled_requests_enabled   = var.sampled_requests_enabled
    metric_name                = var.metric_name

  }

  # AWS Managed Rules
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "managed_rules". The contents of the block are governed respectively using for_each. 
  # 'managed_rules' in for_each is an optional list(object) it will execute only when it is configured. 
  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # override_action is required for managed_rule_group_statements. Set to none, otherwise count to override the default action
      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"

          dynamic "rule_action_override" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
              action_to_use {
                count {}
              }
            }
          }

          dynamic "scope_down_statement" {
            for_each = lookup(rule.value, "scope_down_statement", null) != null ? [rule.value.scope_down_statement] : []
            content {

              # IP Set Reference Statement
              dynamic "ip_set_reference_statement" {
                for_each = lookup(scope_down_statement.value, "ip_set_reference_statement", null) != null ? [scope_down_statement.value.ip_set_reference_statement] : []
                content {
                  arn = ip_set_reference_statement.value.arn
                  dynamic "ip_set_forwarded_ip_config" {
                    for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) != null ? [ip_set_reference_statement.value.ip_set_forwarded_ip_config] : []
                    content {
                      fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                      header_name       = ip_set_forwarded_ip_config.value.header_name
                      position          = ip_set_forwarded_ip_config.value.position
                    }
                  }
                }
              }

              # Geo Match Statement
              dynamic "geo_match_statement" {
                for_each = lookup(scope_down_statement.value, "geo_match_statement", null) != null ? [scope_down_statement.value.geo_match_statement] : []
                content {
                  country_codes = geo_match_statement.value.country_codes
                  dynamic "forwarded_ip_config" {
                    for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) != null ? [geo_match_statement.value.forwarded_ip_config] : []
                    content {
                      fallback_behavior = forwarded_ip_config.value.fallback_behavior
                      header_name       = forwarded_ip_config.value.header_name
                    }
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.rule_visibility_enable_cloudwatch_metrics
        metric_name                = rule.value.name
        sampled_requests_enabled   = var.rule_visibility_enable_sampled_requests
      }
    }
  }


  # IP Set Reference Rule
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "ipset_reference_rules". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.ipset_reference_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action block is required for ipset_reference_rules
      # One of allow, block, count, or captcha, is required when specifying an action.
      # For_each looks for either of the values "allow", "block", "count", "captcha" and executes the action block
      action {
        dynamic "allow" {
          for_each = lookup(rule.value, "action", {}) == "allow" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }
      }

      statement {
        dynamic "ip_set_reference_statement" {
          # 'ip_set_reference_statement' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            arn = ip_set_reference_statement.value.arn
            dynamic "ip_set_forwarded_ip_config" {
              for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) != null ? [ip_set_reference_statement.value.ip_set_forwarded_ip_config] : []
              content {
                fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                header_name       = ip_set_forwarded_ip_config.value.header_name
                position          = ip_set_forwarded_ip_config.value.position
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  # Geo Match Statement Rule
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "geo_match_statement". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.geo_match_statement_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action block is required for geo_match_statement_rules
      # One of allow, block, count, or captcha, is required when specifying an action.
      # For_each looks for either of the values "allow", "block", "count", "captcha" and executes the action block
      action {
        dynamic "allow" {
          for_each = lookup(rule.value, "action", {}) == "allow" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }
      }

      statement {
        dynamic "geo_match_statement" {
          # 'geo_match_statement' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes

            dynamic "forwarded_ip_config" {
              for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) != null ? [geo_match_statement.value.forwarded_ip_config] : []
              content {
                fallback_behavior = forwarded_ip_config.value.fallback_behavior # valid values are MATCH & NO_MATCH 
                header_name       = forwarded_ip_config.value.header_name
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  # Label Match Statement Rule
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "label_match_statement". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.label_match_statement_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action block is required for label_match_statement_rules
      # One of allow, block, count, or captcha, is required when specifying an action.
      # For_each looks for either of the values "allow", "block", "count", "captcha" and executes the action block
      action {
        dynamic "allow" {
          for_each = lookup(rule.value, "action", {}) == "allow" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }
      }

      statement {
        dynamic "label_match_statement" {
          # 'label_match_statement ' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            scope = label_match_statement.value.scope # valid values are LABEL & NAMESPACE
            key   = label_match_statement.value.key
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  # Byte match statement Rule
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "ipset_reference_rules". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.byte_match_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action block is required for byte_match_rule 
      # One of allow, block, count, or captcha, is required when specifying an action.
      # For_each looks for either of the values "allow", "block", "count", "captcha" and executes the action block
      action {
        dynamic "allow" {
          for_each = lookup(rule.value, "action", {}) == "allow" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

      }

      statement {
        dynamic "byte_match_statement" {
          # "byte_match_statment" is an optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string
            dynamic "text_transformation" {
              for_each = byte_match_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
            dynamic "field_to_match" {
              # Only one of all_query_arguments, body, cookies, headers, json_body, method, query_string, single_header, single_query_argument, or uri_path can be specified. An empty configuration block {} should be used when specifying all_query_arguments, body, method, or query_string attributes.  
              for_each = lookup(rule.value.statement, "field_to_match", null) != null ? [rule.value.statement.field_to_match] : []
              content {
                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) != null ? [1] : []

                  content {}
                }
                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) != null ? [1] : []

                  content {}
                }

                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) != null ? [1] : []

                  content {}
                }
                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) != null ? [1] : []

                  content {}
                }
                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []

                  content {}
                }
                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) != null ? [field_to_match.value.cookies] : []
                  content {
                    dynamic "match_pattern" {
                      for_each = cookies.value.match_pattern # You must specify exactly one setting: either "all", "included_cookies" or "excluded_cookies" in "match_patter"
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_cookies = lookup(match_pattern.value, "included_cookies", null)
                        excluded_cookies = lookup(match_pattern.value, "excluded_cookies", null)
                      }
                    }
                    match_scope       = cookies.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                    oversize_handling = cookies.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                  }
                }
                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) != null ? [field_to_match.value.headers] : []
                  content {
                    dynamic "match_pattern" {
                      for_each = headers.value.match_pattern # You must specify exactly one setting: either "all", "included_headers" or "excluded_headers" in "match_patter"
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                      }
                    }
                    match_scope       = headers.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                    oversize_handling = headers.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                  }
                }
                dynamic "json_body" {
                  for_each = lookup(field_to_match.value, "json_body", null) != null ? [field_to_match.value.json_body] : []
                  content {
                    invalid_fallback_behavior = lookup(json_body.value, "invalid_fallback_behavior", null) # Valid values for "invalid_fallback_behavior" are "EVALUATE_AS_STRING", "MATCH" and "NO_MATCH"
                    dynamic "match_pattern" {
                      for_each = json_body.value.match_pattern # You must specify exactly one setting: either "all" or "included_paths" in "match_patter"
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_paths = lookup(match_pattern.value, "included_paths", null)
                      }
                    }
                    match_scope       = json_body.value.match_scope                              # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                    oversize_handling = lookup(json_body.value, "oversize_handling", "CONTINUE") # Valid values for "oversize_handling" are "CONTINUE" (default), "MATCH" and "NO_MATCH".
                  }
                }
                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = lookup(single_header.value, "name", null)
                  }
                }
                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = lookup(single_query_argument.value, "name", null)
                  }
                }
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  # XSS match statement Rule
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "xss_match_rule". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.xss_match_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action block is required for xss_match_rule
      # One of allow, block, count, or captcha, is required when specifying an action.
      # For_each looks for either of the values "allow", "block", "count", "captcha" and executes the action block
      action {
        dynamic "allow" {
          for_each = lookup(rule.value, "action", {}) == "allow" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

      }

      statement {
        dynamic "xss_match_statement" {
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            dynamic "text_transformation" {
              for_each = xss_match_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
            dynamic "field_to_match" {
              # Only one of all_query_arguments, body, cookies, headers, json_body, method, query_string, single_header, single_query_argument, or uri_path can be specified. An empty configuration block {} should be used when specifying all_query_arguments, body, method, or query_string attributes.
              for_each = lookup(rule.value.statement, "field_to_match", null) != null ? [rule.value.statement.field_to_match] : []
              content {
                dynamic "query_string" {
                  for_each = lookup(field_to_match.value, "query_string", null) != null ? [1] : []

                  content {}
                }
                dynamic "method" {
                  for_each = lookup(field_to_match.value, "method", null) != null ? [1] : []

                  content {}
                }

                dynamic "all_query_arguments" {
                  for_each = lookup(field_to_match.value, "all_query_arguments", null) != null ? [1] : []

                  content {}
                }
                dynamic "body" {
                  for_each = lookup(field_to_match.value, "body", null) != null ? [1] : []

                  content {}
                }
                dynamic "uri_path" {
                  for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []

                  content {}
                }
                dynamic "cookies" {
                  for_each = lookup(field_to_match.value, "cookies", null) != null ? [field_to_match.value.cookies] : []
                  content {
                    dynamic "match_pattern" {
                      for_each = cookies.value.match_pattern # You must specify exactly one setting: either "all", "included_cookies" or "excluded_cookies" in "match_patter"
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_cookies = lookup(match_pattern.value, "included_cookies", null)
                        excluded_cookies = lookup(match_pattern.value, "excluded_cookies", null)
                      }
                    }
                    match_scope       = cookies.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                    oversize_handling = cookies.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                  }
                }
                dynamic "headers" {
                  for_each = lookup(field_to_match.value, "headers", null) != null ? [field_to_match.value.headers] : []
                  content {
                    dynamic "match_pattern" {
                      for_each = headers.value.match_pattern
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_headers = lookup(match_pattern.value, "included_headers", null)
                        excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                      }
                    }
                    match_scope       = headers.value.match_scope
                    oversize_handling = headers.value.oversize_handling
                  }
                }
                dynamic "json_body" {
                  for_each = lookup(field_to_match.value, "json_body", null) != null ? [field_to_match.value.json_body] : []
                  content {
                    invalid_fallback_behavior = lookup(json_body.value, "invalid_fallback_behavior", null) # Valid values for "invalid_fallback_behavior" are "EVALUATE_AS_STRING", "MATCH" and "NO_MATCH"
                    dynamic "match_pattern" {
                      for_each = json_body.value.match_pattern
                      content {
                        dynamic "all" {
                          for_each = lookup(match_pattern.value, "all", {})
                          content {}
                        }
                        included_paths = lookup(match_pattern.value, "included_paths", null)
                      }
                    }
                    match_scope       = json_body.value.match_scope                              # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                    oversize_handling = lookup(json_body.value, "oversize_handling", "CONTINUE") # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                  }
                }
                dynamic "single_header" {
                  for_each = lookup(field_to_match.value, "single_header", null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = lookup(single_header.value, "name", null)
                  }
                }
                dynamic "single_query_argument" {
                  for_each = lookup(field_to_match.value, "single_query_argument", null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = lookup(single_query_argument.value, "name", null)
                  }
                }
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }

  # Rate Based Rules
  # The 'rule' optional block, can iterate multiple times if multiple values are passed for the variable "rate_based_rules". The contents of the block are governed respectively using for_each.
  dynamic "rule" {
    for_each = var.rate_based_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # action is required for rate based reference statement
      # One of block, count, or captcha is required when specifying an action.
      # For_each looks for either of the values "block", "count", "captcha" and executes the action block.
      action {

        # Custom reponse body - key - Unique key identifying the custom response body.
        # This is referenced by the custom_response_body_key argument in the Custom Response block.
        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [true] : []
          content {
            dynamic "custom_response" {
              for_each = length(lookup(rule.value, "custom_response", [])) == 0 ? [] : [lookup(rule.value, "custom_response", {})]
              content {
                custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                response_code            = lookup(custom_response.value, "response_code", 403)
                dynamic "response_header" {
                  for_each = lookup(custom_response.value, "response_header", [])
                  content {
                    name  = lookup(response_header.value, "name")
                    value = lookup(response_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = lookup(rule.value, "action", {}) == "captcha" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [true] : []
          content {
            dynamic "custom_request_handling" {
              for_each = length(lookup(rule.value, "custom_request_handling", [])) == 0 ? [] : [lookup(rule.value, "custom_request_handling", {})]
              content {
                dynamic "insert_header" {
                  for_each = lookup(custom_request_handling.value, "insert_header", [])
                  content {
                    name  = lookup(insert_header.value, "name")
                    value = lookup(insert_header.value, "value")
                  }
                }
              }
            }
          }
        }
      }

      statement {
        dynamic "rate_based_statement" {
          # 'rate_based_statement' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
          for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []
          content {
            aggregate_key_type = lookup(rate_based_statement.value, "aggregate_key_type") # Valid Values are "IP" and "FORWARDED_IP".
            limit              = lookup(rate_based_statement.value, "limit")
            dynamic "forwarded_ip_config" {
              for_each = lookup(rate_based_statement.value, "forwarded_ip_config", null) != null ? [rate_based_statement.value.forwarded_ip_config] : []
              content {
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
                header_name       = forwarded_ip_config.value.header_name
              }
            }
            dynamic "scope_down_statement" {
              for_each = lookup(rate_based_statement.value, "scope_down_statement", null)
              content {

                #geo_match_statement
                dynamic "geo_match_statement" {
                  # 'geo_match_statement' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
                  for_each = lookup(scope_down_statement.value, "geo_match_statement", null) != null ? [scope_down_statement.value.geo_match_statement] : []
                  content {
                    country_codes = geo_match_statement.value.country_codes
                    dynamic "forwarded_ip_config" {
                      for_each = lookup(geo_match_statement.value, "forwarded_ip_config", null) != null ? [geo_match_statement.value.forwarded_ip_config] : []
                      content {
                        fallback_behavior = forwarded_ip_config.value.fallback_behavior # valid values are MATCH & NO_MATCH 
                        header_name       = forwarded_ip_config.value.header_name
                      }
                    }
                  }
                }

                #label_match_statement
                dynamic "label_match_statement" {
                  # 'label_match_statement ' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
                  for_each = lookup(scope_down_statement.value, "label_match_statement", null) != null ? [scope_down_statement.value.label_match_statement] : []
                  content {
                    scope = label_match_statement.value.scope # valid values are LABEL & NAMESPACE
                    key   = label_match_statement.value.key
                  }
                }

                #ip_set_reference_statement
                dynamic "ip_set_reference_statement" {
                  # 'ip_set_reference_statement' is optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
                  for_each = lookup(scope_down_statement.value, "ip_set_reference_statement", null) != null ? [scope_down_statement.value.ip_set_reference_statement] : []
                  content {
                    arn = ip_set_reference_statement.value.arn
                    dynamic "ip_set_forwarded_ip_config" {
                      for_each = lookup(ip_set_reference_statement.value, "ip_set_forwarded_ip_config", null) != null ? [ip_set_reference_statement.value.ip_set_forwarded_ip_config] : []
                      content {
                        fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                        header_name       = ip_set_forwarded_ip_config.value.header_name
                        position          = ip_set_forwarded_ip_config.value.position
                      }
                    }
                  }
                }

                #byte_match_statement
                dynamic "byte_match_statement" {
                  # "byte_match_statment" is an optional block so for_each looks for value if it not equal to null, it execute and if it is equal to null it takes default value.
                  for_each = lookup(scope_down_statement.value, "byte_match_statement", null) != null ? [scope_down_statement.value.byte_match_statement] : []
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string
                    dynamic "text_transformation" {
                      for_each = byte_match_statement.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                    dynamic "field_to_match" {
                      # Only one of all_query_arguments, body, cookies, headers, json_body, method, query_string, single_header, single_query_argument, or uri_path can be specified. An empty configuration block {} should be used when specifying all_query_arguments, body, method, or query_string attributes.  
                      for_each = lookup(scope_down_statement.value.byte_match_statement, "field_to_match", null) != null ? [scope_down_statement.value.byte_match_statement.field_to_match] : []
                      content {
                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) != null ? [1] : []
                          content {}
                        }
                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) != null ? [1] : []
                          content {}
                        }
                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) != null ? [1] : []
                          content {}
                        }
                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) != null ? [1] : []
                          content {}
                        }
                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []
                          content {}
                        }
                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) != null ? [field_to_match.value.cookies] : []
                          content {
                            dynamic "match_pattern" {
                              for_each = cookies.value.match_pattern # You must specify exactly one setting: either "all", "included_cookies" or "excluded_cookies" in "match_patter"
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_cookies = lookup(match_pattern.value, "included_cookies", null)
                                excluded_cookies = lookup(match_pattern.value, "excluded_cookies", null)
                              }
                            }
                            match_scope       = cookies.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                            oversize_handling = cookies.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                          }
                        }
                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) != null ? [field_to_match.value.headers] : []
                          content {
                            dynamic "match_pattern" {
                              for_each = headers.value.match_pattern # You must specify exactly one setting: either "all", "included_headers" or "excluded_headers" in "match_patter"
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                              }
                            }
                            match_scope       = headers.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                            oversize_handling = headers.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                          }
                        }
                        dynamic "json_body" {
                          for_each = lookup(field_to_match.value, "json_body", null) != null ? [field_to_match.value.json_body] : []
                          content {
                            invalid_fallback_behavior = lookup(json_body.value, "invalid_fallback_behavior", null) # Valid values for "invalid_fallback_behavior" are "EVALUATE_AS_STRING", "MATCH" and "NO_MATCH"
                            dynamic "match_pattern" {
                              for_each = json_body.value.match_pattern # You must specify exactly one setting: either "all" or "included_paths" in "match_patter"
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_paths = lookup(match_pattern.value, "included_paths", null)
                              }
                            }
                            match_scope       = json_body.value.match_scope                              # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                            oversize_handling = lookup(json_body.value, "oversize_handling", "CONTINUE") # Valid values for "oversize_handling" are "CONTINUE" (default), "MATCH" and "NO_MATCH".
                          }
                        }
                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) != null ? [field_to_match.value.single_header] : []
                          content {
                            name = lookup(single_header.value, "name", null)
                          }
                        }
                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) != null ? [field_to_match.value.single_query_argument] : []
                          content {
                            name = lookup(single_query_argument.value, "name", null)
                          }
                        }
                      }
                    }
                  }
                }

                #xss_match_statement
                dynamic "xss_match_statement" {
                  for_each = lookup(scope_down_statement.value, "xss_match_statement", null) != null ? [scope_down_statement.value.xss_match_statement] : []
                  content {
                    dynamic "text_transformation" {
                      for_each = xss_match_statement.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                    dynamic "field_to_match" {
                      # Only one of all_query_arguments, body, cookies, headers, json_body, method, query_string, single_header, single_query_argument, or uri_path can be specified. An empty configuration block {} should be used when specifying all_query_arguments, body, method, or query_string attributes.
                      for_each = lookup(scope_down_statement.value.xss_match_statement, "field_to_match", null) != null ? [scope_down_statement.value.xss_match_statement.field_to_match] : []
                      content {
                        dynamic "query_string" {
                          for_each = lookup(field_to_match.value, "query_string", null) != null ? [1] : []

                          content {}
                        }
                        dynamic "method" {
                          for_each = lookup(field_to_match.value, "method", null) != null ? [1] : []

                          content {}
                        }

                        dynamic "all_query_arguments" {
                          for_each = lookup(field_to_match.value, "all_query_arguments", null) != null ? [1] : []

                          content {}
                        }
                        dynamic "body" {
                          for_each = lookup(field_to_match.value, "body", null) != null ? [1] : []

                          content {}
                        }
                        dynamic "uri_path" {
                          for_each = lookup(field_to_match.value, "uri_path", null) != null ? [1] : []

                          content {}
                        }
                        dynamic "cookies" {
                          for_each = lookup(field_to_match.value, "cookies", null) != null ? [field_to_match.value.cookies] : []
                          content {
                            dynamic "match_pattern" {
                              for_each = cookies.value.match_pattern # You must specify exactly one setting: either "all", "included_cookies" or "excluded_cookies" in "match_patter"
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_cookies = lookup(match_pattern.value, "included_cookies", null)
                                excluded_cookies = lookup(match_pattern.value, "excluded_cookies", null)
                              }
                            }
                            match_scope       = cookies.value.match_scope       # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                            oversize_handling = cookies.value.oversize_handling # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                          }
                        }
                        dynamic "headers" {
                          for_each = lookup(field_to_match.value, "headers", null) != null ? [field_to_match.value.headers] : []
                          content {
                            dynamic "match_pattern" {
                              for_each = headers.value.match_pattern
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_headers = lookup(match_pattern.value, "included_headers", null)
                                excluded_headers = lookup(match_pattern.value, "excluded_headers", null)
                              }
                            }
                            match_scope       = headers.value.match_scope
                            oversize_handling = headers.value.oversize_handling
                          }
                        }
                        dynamic "json_body" {
                          for_each = lookup(field_to_match.value, "json_body", null) != null ? [field_to_match.value.json_body] : []
                          content {
                            invalid_fallback_behavior = lookup(json_body.value, "invalid_fallback_behavior", null) # Valid values for "invalid_fallback_behavior" are "EVALUATE_AS_STRING", "MATCH" and "NO_MATCH"
                            dynamic "match_pattern" {
                              for_each = json_body.value.match_pattern
                              content {
                                dynamic "all" {
                                  for_each = lookup(match_pattern.value, "all", {})
                                  content {}
                                }
                                included_paths = lookup(match_pattern.value, "included_paths", null)
                              }
                            }
                            match_scope       = json_body.value.match_scope                              # Valid values for "match_scope" are "ALL", "KEY" and "VALUE".
                            oversize_handling = lookup(json_body.value, "oversize_handling", "CONTINUE") # Valid values for "oversize_handling" are "CONTINUE", "MATCH" and "NO_MATCH".
                          }
                        }
                        dynamic "single_header" {
                          for_each = lookup(field_to_match.value, "single_header", null) != null ? [field_to_match.value.single_header] : []
                          content {
                            name = lookup(single_header.value, "name", null)
                          }
                        }
                        dynamic "single_query_argument" {
                          for_each = lookup(field_to_match.value, "single_query_argument", null) != null ? [field_to_match.value.single_query_argument] : []
                          content {
                            name = lookup(single_query_argument.value, "name", null)
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = lookup(rule.value, "rule_label", {})
        content {
          name = rule_label.value.name
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value.visibility_config
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }
  tags = local.module_tags
}

resource "aws_wafv2_web_acl_logging_configuration" "wafv2-aws_wafv2_web_acl_logging_configuration-acl" {

  log_destination_configs = [var.log_destination_arn]
  resource_arn            = aws_wafv2_web_acl.wafv2-web-acl.arn

  # "redacted_fields" is an optional block, this block will execute only if the user configures.
  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {

      dynamic "single_header" {
        # 'single_header' is an optional dynamic block so the for_each checks for the lenght of single_header if it is 0, it takes default value and if it not 0 the it will take user's input. 
        for_each = length(lookup(redacted_fields.value, "single_header", {})) == 0 ? [] : [lookup(redacted_fields.value, "single_header", {})]
        content {
          name = lookup(single_header.value, "name", null)
        }
      }

      dynamic "method" {
        for_each = length(lookup(redacted_fields.value, "method", {})) == 0 ? [] : [lookup(redacted_fields.value, "method", {})]
        content {}
      }

      dynamic "query_string" {
        for_each = length(lookup(redacted_fields.value, "query_string", {})) == 0 ? [] : [lookup(redacted_fields.value, "query_string", {})]
        content {}
      }

      dynamic "uri_path" {
        for_each = length(lookup(redacted_fields.value, "uri_path", {})) == 0 ? [] : [lookup(redacted_fields.value, "uri_path", {})]
        content {}
      }

    }
  }

  dynamic "logging_filter" {
    for_each = length(var.logging_filter) != 0 ? [var.logging_filter] : []
    content {
      default_behavior = lookup(logging_filter.value, "default_behavior", "KEEP")

      dynamic "filter" {
        for_each = length(lookup(logging_filter.value, "filter", {})) == 0 ? [] : toset(lookup(logging_filter.value, "filter"))
        content {
          behavior    = lookup(filter.value, "behavior", "KEEP")
          requirement = lookup(filter.value, "requirement", "MEETS_ANY")

          dynamic "condition" {
            for_each = length(lookup(filter.value, "condition", {})) == 0 ? [] : toset(lookup(filter.value, "condition"))
            content {
              dynamic "action_condition" {
                for_each = length(lookup(condition.value, "action_condition", {})) == 0 ? [] : [lookup(condition.value, "action_condition", {})]
                content {
                  action = lookup(action_condition.value, "action", "ALLOW")
                }
              }

              dynamic "label_name_condition" {
                for_each = length(lookup(condition.value, "label_name_condition", {})) == 0 ? [] : [lookup(condition.value, "label_name_condition", {})]
                content {
                  label_name = lookup(label_name_condition.value, "label_name")
                }
              }
            }
          }
        }
      }
    }
  }
}

# WAF Web ACL association for ALB or API Gateway

resource "aws_wafv2_web_acl_association" "waf2_web_acl_association" {
  count        = var.enable_webacl_resource_association ? 1 : 0
  resource_arn = var.resource_arn_to_associate_with_web_acl
  web_acl_arn  = aws_wafv2_web_acl.wafv2-web-acl.arn
}
