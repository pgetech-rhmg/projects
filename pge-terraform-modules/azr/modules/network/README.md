# Network Module

## PGE FinOps Tags Configuration

All resources created by this module require PGE FinOps compliant tags:

```hcl
tags = {
  AppID              = "APP-12345"                   # Application identifier
  Environment        = "Prod"                        # Environment (Dev/Test/QA/Prod)
  DataClassification = "Internal"                    # Data sensitivity
  CRIS               = "High"                        # Risk level (High/Medium/Low)
  Notify             = "platform-team@pge.com"       # Notification email(s)
  Owner              = "john.doe@pge.com"            # Owner LANID(s)
  Compliance         = "None"                        # Compliance type
  Order              = "1234567"                     # Purchase order (7-9 digits)
}
```

The module automatically merges these tags with workspace tracking information (`pge_team`, `tfc_wsname`, `tfc_wsid`) for complete SAF2.0 compliance.

<!-- BEGIN_TF_DOCS -->
<!-- Run scripts/generate-readme.sh network azr to update this section. -->
<!-- END_TF_DOCS -->
