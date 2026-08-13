locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  # Whether the module generates the admin password itself. Driving this off
  # `var.admin_password == null` alone breaks when the caller passes a value
  # that is unknown at plan time (e.g. random_password.x.result created in the
  # same run): `unknown == null` is itself unknown, so `count` becomes unknown
  # and plan fails ("Invalid count argument"). `generate_admin_password` lets a
  # caller state the intent explicitly and keep count plan-known; when left null
  # we fall back to the original null-check for backward compatibility.
  generate_password = var.generate_admin_password != null ? var.generate_admin_password : var.admin_password == null
}
