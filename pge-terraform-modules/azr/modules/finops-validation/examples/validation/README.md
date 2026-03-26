# FinOps Validation Module Example

This example demonstrates how to use the FinOps Validation module to validate partner configurations against an approved FinOps CSV file.

## Overview

The FinOps Validation module parses a CSV file containing approved AppID and Order number combinations, then validates partner configurations against these approved pairs.

## Files

- `terraform.tf` - Terraform configuration
- `main.tf` - Module invocation
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `terraform.auto.tfvars` - Example variable values

## Usage

### 1. Customize the FinOps CSV Content

Update the `finops_csv_content` variable in `terraform.auto.tfvars` with your actual FinOps CSV data. The module expects:
- CSV format with headers
- AppID in column 6 (index 5)
- Order# in column 9 (index 8)

### 2. Define Partner Configurations

Update the `partner_configs` variable with your actual partner configurations. Each partner must include:
- `tags.AppID`: The application identifier
- `tags.Order`: The order number

### 3. Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

The module provides three outputs:

1. **approved_partner_configs**: Partners whose AppID and Order# match the CSV
2. **finops_validation_status**: Status for each partner (approved true/false)
3. **finops_mismatches**: Details of validation failures with specific reasons

## Example Results

### Approved Partners

Partners with matching AppID and Order# combinations:
```
{
  partner1 = {
    tags = {
      AppID = "APP-1001"
      Order = "811205"
    }
  }
}
```

### Mismatches

Partners with validation failures:
```
[
  {
    partner_name = "partner3"
    app_id       = "APP-9999"
    order        = "999999"
    approved     = false
    reason       = "AppID and Order# do not match FinOps CSV"
  }
]
```

## Notes

- The module automatically skips CSV header rows
- Empty values in CSV (marked as "(blank)") are filtered out
- Partner configs with missing AppID or Order# tags are considered not approved

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_validation"></a> [finops\_validation](#module\_finops\_validation) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_finops_csv_content"></a> [finops\_csv\_content](#input\_finops\_csv\_content) | Raw contents of the FinOps CSV file | `string` | `""` | no |
| <a name="input_partner_configs"></a> [partner\_configs](#input\_partner\_configs) | Map of partner configurations to validate | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_approved_partner_configs"></a> [approved\_partner\_configs](#output\_approved\_partner\_configs) | Map of partners approved for vending |
| <a name="output_finops_mismatches"></a> [finops\_mismatches](#output\_finops\_mismatches) | List of partners with validation mismatches |
| <a name="output_finops_validation_status"></a> [finops\_validation\_status](#output\_finops\_validation\_status) | Validation status for each partner |


<!-- END_TF_DOCS -->