# Variables for tags

variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for Glue Trigger

variable "glue_trigger_name" {
  description = "The name of the trigger."
  type        = string
}

variable "glue_trigger_type" {
  description = "The type of trigger.Valid values are CONDITIONAL, ON_DEMAND, and SCHEDULED."
  type        = string
  validation {
    condition = anytrue([
      var.glue_trigger_type == "CONDITIONAL",
      var.glue_trigger_type == "ON_DEMAND",
    var.glue_trigger_type == "SCHEDULED"])
    error_message = "Error! Valid values for glue_trigger_type are CONDITIONAL, ON_DEMAND, and SCHEDULED."
  }
}

variable "glue_trigger_description" {
  description = "A description of the glue trigger."
  type        = string
  default     = null
}

variable "glue_trigger_enabled" {
  description = "Start the trigger. Defaults to true."
  type        = bool
  default     = true
}

variable "glue_trigger_schedule" {
  description = "A cron expression used to specify the schedule."
  type        = string
  default     = null
}

variable "glue_trigger_start_on_creation" {
  description = "Set to true to start SCHEDULED and CONDITIONAL triggers when created. True is not supported for ON_DEMAND triggers."
  type        = bool
  default     = null
}

variable "glue_trigger_workflow_name" {
  description = "A workflow to which the trigger should be associated to. Every workflow graph (DAG) needs a starting trigger (ON_DEMAND or SCHEDULED type) and can contain multiple additional CONDITIONAL triggers."
  type        = string
  default     = null
}

variable "glue_trigger_actions" {
  description = "List of actions initiated by this trigger when it fires."
  type        = list(map(string))

  # job_name conflicts with crawler_name
  validation {
    condition     = alltrue([for va in var.glue_trigger_actions : (contains(keys(va), "job_name") && contains(keys(va), "crawler_name"))]) ? false : true
    error_message = "Error! For Glue trigger actions , job_name conflicts with crawler_name. Only one can be specified for the variable 'glue_trigger_actions'!."
  }
}

variable "glue_trigger_predicate" {
  description = "A predicate to specify when the new trigger should fire.Required when trigger type is CONDITIONAL."
  type        = list(map(string))
  default     = []

  # If job_name is specified, state must also be specified.
  validation {
    condition     = alltrue([for js in var.glue_trigger_predicate : (contains(keys(js), "job_name") && contains(keys(js), "state")) || (!contains(keys(js), "job_name") && !contains(keys(js), "state"))]) ? true : false
    error_message = "Error! For Glue trigger predicate, if the 'job_name' is specified, 'state' must also be specified for the variable 'glue_trigger_predicate'!"
  }

  # job_name conflicts with crawler_name.
  validation {
    condition     = anytrue([for js in var.glue_trigger_predicate : (contains(keys(js), "job_name") && contains(keys(js), "crawler_name"))]) ? false : true
    error_message = "Error! For Glue trigger predicate , the 'job_name' conflicts with 'crawler_name'. Only one can be specified for the variable 'glue_trigger_predicate'!"
  }

  # For state - the values supported are SUCCEEDED, STOPPED, TIMEOUT and FAILED.
  validation {
    condition     = alltrue([for ki, vi in var.glue_trigger_predicate : vi == "SUCCEEDED" && vi == "STOPPED" && vi == "TIMEOUT" && vi == "FAILED" if ki == "state"])
    error_message = "Error! enter a valid value for glue_trigger_predicate - state. The values supported are SUCCEEDED, STOPPED, TIMEOUT and FAILED."
  }

  # state conflicts with crawl_state.
  validation {
    condition     = anytrue([for sc in var.glue_trigger_predicate : (contains(keys(sc), "state") && contains(keys(sc), "crawl_state"))]) ? false : true
    error_message = "Error! For Glue trigger predicate , the 'state' conflicts with 'crawl_state'. Only one can be specified for the variable 'glue_trigger_predicate'!"
  }

  # If crawl_state is specified, crawler_name must also be specified.
  validation {
    condition     = alltrue([for cs in var.glue_trigger_predicate : (contains(keys(cs), "crawl_state") && contains(keys(cs), "crawler_name")) || (!contains(keys(cs), "crawl_state") && !contains(keys(cs), "crawler_name"))]) ? true : false
    error_message = "Error! For Glue trigger predicate, if the 'crawl_state' is specified, 'crawler_name' must also be specified for the variable 'glue_trigger_predicate'!"
  }

  # crawl_state - Valid values supported are SUCCEEDED, STOPPED, TIMEOUT and FAILED.
  validation {
    condition     = alltrue([for ki, vi in var.glue_trigger_predicate : vi == "SUCCEEDED" && vi == "STOPPED" && vi == "TIMEOUT" && vi == "FAILED" if ki == "crawl_state"])
    error_message = "Error! enter a valid value for glue_trigger_predicate - crawl_state. The values supported are SUCCEEDED, STOPPED, TIMEOUT and FAILED."
  }
}

variable "event_batching_condition" {
  description = "Batch condition that must be met (specified number of events received or batch time window expired) before EventBridge event trigger fires."
  type        = map(number)
  default     = {}
}

