#
# Filename    : modules/validate-pge-tags/variables.tf
# Date        : 07 Feb 2022
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : variables for the tag validation module, 
#               the conditions used in this file, validate the tags object
#

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)

  validation {
    condition = (
      can(var.tags["Environment"]) &&
      contains(["Dev", "Test", "QA", "Prod"], var.tags["Environment"])
    )
    error_message = "An Environment tag is required and case-senstive,valid values for Environment are (Dev, Test, QA, Prod)."
  }

  validation {
    condition = (
      can(var.tags["AppID"]) &&
      can(regex("APP-\\d+", var.tags["AppID"]))
    )
    error_message = "AppID tag is required and allowed format of the AppID is APP-####."
  }

  validation {
    condition = (
      can(var.tags["DataClassification"]) &&
      contains(["Public", "Internal", "Confidential", "Restricted", "Privileged", "Confidential-BCSI", "Restricted-BCSI"], var.tags["DataClassification"])
    )
    error_message = "DataClassification tag is required and case-senstive,valid values for DataClassification are (Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI)."
  }

  validation {
    condition = (
      can(var.tags["CRIS"]) &&
      contains(["High", "Medium", "Low"], var.tags["CRIS"])
    )
    error_message = "CRIS tag is required and case-senstive,valid values for Cyber Risk Impact Score are High, Medium, Low (only one)."
  }

  validation {
    condition = (
      can(var.tags["Owner"]) &&
      can(regex("^(?:[^_\n]*_){2}[^_\n]*", var.tags["Owner"]))
    )
    error_message = "Owner tag is required and three valid values of owners separated by _ is required (Owner1_Owner2_0wner3), e.g. AMPS Director, Client Owner and IT Lead."
  }

  validation {
    condition = (
      can(var.tags["Notify"]) && alltrue([
        for aliases in split("_", var.tags["Notify"]) : can(regex("^\\w+([\\.!-/:[-`{-~]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
      ])
    )
    error_message = "Notify tag is required and valid values should be a group or list of email addresses. separated by underscores _ (s7aw@pge.com_pt26@pge.com)."
  }

  validation {
    condition = (
      can(var.tags["Compliance"]) && alltrue([
        for aliases in split("_", var.tags["Compliance"]) : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], aliases)
      ])
    )
    error_message = "Compliance tag is required and case-senstive,valid values for Compliance are SOX, HIPAA, CCPA, BCSI or None. separated by underscores _ (SOX_HIPAA_CCPA)."
  }

  validation {
    condition = (
      can(var.tags["Order"]) &&
      can(regex("^\\d{7,9}$", var.tags["Order"]))
    )
    error_message = "Order tag is required and must be a number between 7 and 9 digits."
  }
}
