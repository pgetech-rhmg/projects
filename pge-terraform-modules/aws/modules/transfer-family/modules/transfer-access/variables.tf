#Variables for transfer family access
variable "external_id" {
  description = "The SID of a group in the directory connected to the Transfer Server (e.g., S-1-1-12-1234567890-123456789-1234567890-1234)."
  type        = string

  validation {
    condition = anytrue([
      can(regex("^S-\\d{1}([-]*)\\d{1}([-]*)\\d{2}([-]*)\\d{10}([-]*)\\d{10}([-]*)\\d{10}([-]*)\\d{4}", var.external_id))
    ])
    error_message = "Enter a valid external id."
  }
}

variable "server_id" {
  description = "The Server ID of the Transfer Server (e.g., s-12345678)."
  type        = string
}

variable "home_directory" {
  description = "The landing directory (folder) for a user when they log in to the server using their SFTP client. It should begin with a /. The first item in the path is the name of the home bucket and the rest is the home directory."
  type        = string
  default     = null
}

variable "home_directory_mappings" {
  description = <<-DOC
    entry:
       Represents an entry and a target.
    target:
      Represents the map target.
  DOC

  type = object({
    entry  = string
    target = string
  })

  default = {
    entry  = null
    target = null
  }
}

variable "home_directory_type" {
  description = "The type of landing directory (folder) you mapped for your users' home directory. Valid values are PATH and LOGICAL."
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.home_directory_type == null,
      var.home_directory_type == "PATH",
      var.home_directory_type == "LOGICAL"
    ])
    error_message = "Error! Valid values for home directory type are PATH and LOGICAL."
  }
}

variable "policy" {
  description = "An IAM JSON policy document that scopes down user access to portions of their Amazon S3 bucket."
  type        = string
  default     = null
}

variable "posix_profile" {
  description = <<-DOC
    gid:
      The POSIX group ID used for all EFS operations by this user.
    uid:
      The POSIX user ID used for all EFS operations by this user.
    secondary_gids:
      The secondary POSIX group IDs used for all EFS operations by this user.
  DOC

  type = object({
    gid            = number
    uid            = number
    secondary_gids = list(string)
  })

  default = {
    gid            = null
    uid            = null
    secondary_gids = null
  }

  validation {
    condition     = var.posix_profile.gid == null ? true : var.posix_profile.gid >= 0 && var.posix_profile.gid <= 4294967295
    error_message = "Error! gid to be in the range (0 - 4294967295)."
  }

  validation {
    condition     = var.posix_profile.uid == null ? true : var.posix_profile.uid >= 0 && var.posix_profile.uid <= 4294967295
    error_message = "Error! uid to be in the range (0 - 4294967295)."
  }

  validation {
    condition     = var.posix_profile.secondary_gids == null ? true : alltrue([for i in var.posix_profile.secondary_gids : i >= 0 && i <= 4294967295])
    error_message = "Error! secondary_gids to be in the range (0 - 4294967295)."
  }

  validation {
    condition     = var.posix_profile.gid != null && var.posix_profile.uid == null ? false : true
    error_message = "Error! uid is required."
  }

  validation {
    condition     = var.posix_profile.uid != null && var.posix_profile.gid == null ? false : true
    error_message = "Error! gid is required."
  }
}

variable "role" {
  description = "Amazon Resource Name (ARN) of an IAM role that allows the service to controls your user’s access to your Amazon S3 bucket."
  type        = string
}