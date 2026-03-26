/*
 * # AWS Glue Classifier module.
 * Terraform module which creates SAF2.0 Glue Classifier in AWS.
 * It is only valid to create one type of classifier (csv, grok, JSON, or XML). Changing classifier types will recreate the classifier.
*/

#
#  Filename    : aws/modules/glue/modules/glue-classifier/main.tf
#  Date        : 07 September 2022
#  Author      : TCS
#  Description : Glue Classifier Creation
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

# Module      : Creation of Glue Classifier
# Description : This terraform module creates a Glue Classifier.

resource "aws_glue_classifier" "glue_classifier" {

  name = var.classifier_name

  dynamic "csv_classifier" {
    for_each = var.csv_classifier
    content {
      allow_single_column    = lookup(csv_classifier.value, "allow_single_column", null)
      contains_header        = lookup(csv_classifier.value, "contains_header", null)
      delimiter              = lookup(csv_classifier.value, "delimiter", null)
      disable_value_trimming = lookup(csv_classifier.value, "disable_value_trimming", null)
      header                 = lookup(csv_classifier.value, "header", null)
      quote_symbol           = lookup(csv_classifier.value, "quote_symbol", null)
    }
  }

  dynamic "grok_classifier" {
    for_each = var.grok_classifier != null ? [true] : []
    content {
      classification  = var.grok_classifier.classification
      custom_patterns = try(grok_classifier.value, "custom_patterns", null)
      grok_pattern    = var.grok_classifier.grok_pattern
    }
  }

  dynamic "json_classifier" {
    for_each = var.json_path != null ? [true] : []
    content {
      json_path = var.json_path
    }
  }

  dynamic "xml_classifier" {
    for_each = var.xml_classifier != null ? [true] : []
    content {
      classification = var.xml_classifier.classification
      row_tag        = var.xml_classifier.row_tag
    }
  }

}
