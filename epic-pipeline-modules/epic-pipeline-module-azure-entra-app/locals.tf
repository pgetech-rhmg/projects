locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  # Microsoft Graph well-known application ID — the resource most app
  # registrations request permissions against.
  microsoft_graph_app_id = "00000003-0000-0000-c000-000000000000"
}
