#Fleet
output "id" {
  description = "Unique identifier (ID) of the appstream fleet."
  value       = module.fleet.id
}

output "arn" {
  description = " ARN of the appstream fleet."
  value       = module.fleet.arn
}

output "state" {
  description = "State of the fleet. Can be STARTING, RUNNING, STOPPING or STOPPED"
  value       = module.fleet.state
}

output "created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the fleet was created."
  value       = module.fleet.created_time
}

output "compute_capacity" {
  description = "Describes the capacity status for a fleet."
  value       = module.fleet.compute_capacity
}

#Fleet_Stack Association
output "id_fleet_stack" {
  description = "Unique ID of the appstream stack fleet association, composed of the fleet_name and stack_name separated by a slash (/)."
  value       = module.fleet_stack.id_fleet_stack
}

# ❌ COMMENTED OUT FOR DOMAIN-JOINED DEPLOYMENTS
# User_Stack Association outputs - NOT REQUIRED for domain authentication
# Domain users are managed through Active Directory, not individual user-stack associations
# output "id_user_stack" {
#   description = "Unique ID of the appstream User Stack association."
#   value       = module.user_stack.id_user_stack
# }

# ❌ COMMENTED OUT - IMAGE_BUILDER MODULE IS COMMENTED OUT
# Image builder outputs - Only needed when image_builder module is active
# Uncomment these when building custom images with image_builder module
# #image_builder
# output "appstream_image_arn" {
#   description = "ARN of the appstream image builder."
#   value       = module.image_builder.appstream_image_arn
# }
# 
# output "appstream_image_created_time" {
#   description = "Date and time, in UTC and extended RFC 3339 format, when the image builder was created."
#   value       = module.image_builder.appstream_image_created_time
# }
# 
# output "appstream_image_id" {
#   description = "The name of the image builder."
#   value       = module.image_builder.appstream_image_id
# }
# 
# output "appstream_image_state" {
#   description = "State of the image builder. Can be: PENDING, UPDATING_AGENT, RUNNING, STOPPING, STOPPED, REBOOTING, SNAPSHOTTING, DELETING, FAILED, UPDATING, PENDING_QUALIFICATION"
#   value       = module.image_builder.appstream_image_state
# }

# ❌ COMMENTED OUT FOR DOMAIN-JOINED DEPLOYMENTS
# User outputs - NOT REQUIRED for domain authentication
# Domain users are managed in Active Directory, not AppStream user pools
# Individual user details are not relevant when using domain authentication
# output "appstream_user_arn" {
#   description = "ARN of the appstream user."
#   value       = module.user_appstream.appstream_user_arn
# }

# output "appstream_user_created_time" {
#   description = "Date and time, in UTC and extended RFC 3339 format, when the user was created."
#   value       = module.user_appstream.appstream_user_created_time
# }

# output "appstream_user_id" {
#   description = "Unique ID of the appstream user."
#   value       = module.user_appstream.appstream_user_id
# }

#stack
output "appstream_stack_arn" {
  description = "ARN of the appstream stack."
  value       = module.stack_appstream.appstream_stack_arn
}

output "appstream_stack_created_time" {
  description = "Date and time, in UTC and extended RFC 3339 format, when the stack was created."
  value       = module.stack_appstream.appstream_stack_created_time
}

output "appstream_stack_id" {
  description = "Unique ID of the appstream stack."
  value       = module.stack_appstream.appstream_stack_id
}

# ❌ COMMENTED OUT FOR DOMAIN-JOINED IMAGE BUILDER DEPLOYMENTS
# Directory config outputs - NOT REQUIRED when using pre-domain-joined images
# These outputs are only relevant when using directory_config module
# output "appstream_directory_config" {
#   description = "Unique identifier (ID) of the appstream directory config."
#   value       = module.directory_config.appstream_directory_config
# }
# 
# output "appstream_created_time" {
#   description = "Date and time, in UTC and extended RFC 3339 format, when the directory config was created."
#   value       = module.directory_config.appstream_created_time
# }