variable "directory_name" {
  description = "Fully qualified name of the directory."
  type        = string
}

variable "organizational_unit_names" {
  description = "Distinguished names of the organizational units for computer accounts."
  type        = list(string)
}

variable "account_name" {
  description = "User name of the account. This account must have the following privileges: create computer objects, join computers to the domain, and change/reset the password on descendant computer objects for the organizational units specified."
  type        = string
}

variable "account_password" {
  description = "Password for the account."
  type        = string
}