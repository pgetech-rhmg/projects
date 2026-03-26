# Example FinOps CSV content with AppID (column 6) and Order# (column 9)
finops_csv_content = <<-EOT
HeaderCol1,HeaderCol2,HeaderCol3,HeaderCol4,HeaderCol5,AppID,HeaderCol7,HeaderCol8,Order
Partner1,Data,Data,Data,Data,APP-1001,Data,Data,811205
Partner2,Data,Data,Data,Data,APP-1002,Data,Data,811206
EOT

# Example partner configurations to validate
partner_configs = {
  partner1 = {
    subscription_name = "partner1-dev"
    tags = {
      AppID = "APP-1001"
      Order = "811205"
    }
  }
  partner2 = {
    subscription_name = "partner2-prod"
    tags = {
      AppID = "APP-1002"
      Order = "811206"
    }
  }
  partner3 = {
    subscription_name = "partner3-test"
    tags = {
      AppID = "APP-9999"
      Order = "999999"
    }
  }
}
