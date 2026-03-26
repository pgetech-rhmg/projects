#Variables for record
variable "records" {
  description = "The list of records."
  type        = any

  validation {
    condition     = alltrue([for element in var.records : contains(["A", "CAA", "CNAME", "DS", "MX", "NAPTR", "NS", "PTR", "SOA", "SPF", "SRV", "TXT"], lookup(element, "type"))])
    error_message = "Error! enter a valid value for record type."
  }

  validation {
    condition     = alltrue(flatten([for val in var.records : [for ki, vi in val : can(regex("^\\d+$", vi)) if ki == "ttl"]]))
    error_message = "Error! enter a number for record ttl."
  }

  validation {
    condition     = anytrue([for va in var.records : (contains(keys(va), "records") && contains(keys(va), "alias"))]) ? false : true
    error_message = "Error! records conflicts with alias."
  }

  validation {
    condition     = anytrue([for element in var.records : length(regexall("_routing_policy", join("", keys(element)))) > 1]) ? false : true
    error_message = "Error! only one routing policy is allowed in a record."
  }

  validation {
    condition     = alltrue([for element in var.records : length(regexall("_routing_policy", join("", keys(element)))) == 1 && length(regexall("set_identifier", join("", keys(element)))) == 1 || length(regexall("_routing_policy", join("", keys(element)))) == 0 && length(regexall("set_identifier", join("", keys(element)))) == 0])
    error_message = "Error! if routing policy is specified setidentifier should be given."
  }
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}