#
# Filename    : modules/utils/modules/workspace-info/getws.ps1
# Date        : 20 Apr 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : powershell script to output json value for data external
#

if ([string]::IsNullOrEmpty($Env:TF_VAR_workspace_name)) {
  $WS_DIR = [System.Environment]::CurrentDirectory
} else {
  $WS_DIR = $Env:TF_VAR_workspace_name
}

if ([string]::IsNullOrEmpty($Env:TF_VAR_workspace_id)) {
  $WS_USR = $Env:USERNAME
} else {
  $WS_USR = $Env:TF_VAR_workspace_id
}

ConvertTo-Json @{
  name = $WS_DIR
  id = $WS_USR
}
