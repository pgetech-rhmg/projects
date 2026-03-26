# Variables for Glue Classifier
variable "classifier_name" {
  description = "The name of the classifier."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]", var.classifier_name))
    error_message = "Error! Glue Classifier Name can only contain alphanumeric characters (A-Z), numbers(0-9), underscores (_) and hyphens (-)."
  }
  validation {
    condition     = length(var.classifier_name) <= 255
    error_message = "Errror!  The length of Glue Classifier Name is less then or equal to 255."
  }
}

variable "csv_classifier" {
  description = "A classifier for CSV content."
  type        = list(any)
  default     = []

  # For the variable 'csv_classifier' with key 'contains_header' - The values supported are "ABSENT", "PRESENT", or "UNKNOWN"

  validation {
    condition     = alltrue(flatten([for element in var.csv_classifier : [for ki, vi in element : contains(["PRESENT", "ABSENT", "UNKNOWN"], vi) if ki == "contains_header"]]))
    error_message = "Error! enter a valid value for the variable 'csv_classifier' - for the value 'contains_header'. The values supported are ABSENT, PRESENT and UNKNOWN."
  }
}

variable "grok_classifier" {
  description = "A classifier that uses GROK patterns."
  type        = map(string)
  default     = null
}

variable "json_path" {
  description = "A JsonPath string defining the JSON data for the classifier to classify."
  type        = string
  default     = null
}

variable "xml_classifier" {
  description = "A classifier for XML content."
  type        = map(string)
  default     = null
}

