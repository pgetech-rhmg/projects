#
# Filename    : README.md
# Date        : 11 Mar 2026
# Author      : PGE
# Description : Documentation for the FinOps Validation module
#
# BEGIN_TF_DOCS
# placeholder for terraform-docs generation
# END_TF_DOCS

# FinOps Validation Module

This Terraform module validates partner configurations against an approved FinOps CSV file, ensuring cloud resource provisioning aligns with organizational finance and billing requirements.

## Features

- **CSV Parsing**: Extracts AppID and Order number pairs from FinOps CSV files
- **Configuration Validation**: Validates partner AppID/Order combinations against approved pairs
- **Detailed Status**: Generates comprehensive validation status for each partner
- **Mismatch Reporting**: Identifies validation failures with specific reasons
- **Partner Filtering**: Automatically filters approved partners for downstream vending operations
- **Flexible Input**: Supports complex partner configuration structures

## Usage

```hcl
module "finops_validation" {
  source              = "app.terraform.io/pgetech/azure/finops-validation"
  finops_csv_content  = file("${path.module}/approved_partners.csv")
  partner_configs = {
    partner1 = {
      tags = {
        AppID = "APP-1001"
        Order = "811205"
      }
    }
  }
}
```

## CSV Format

The FinOps CSV file must contain:
- **Column 6 (index 5)**: Application ID (AppID)
- **Column 9 (index 8)**: Order Number

Example:
```csv
HeaderCol1,HeaderCol2,HeaderCol3,HeaderCol4,HeaderCol5,AppID,HeaderCol7,HeaderCol8,Order
Partner1,Data,Data,Data,Data,APP-1001,Data,Data,811205
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| partner_configs | Map of partner configs to validate. Must include tags.AppID and tags.Order. | any | yes |
| finops_csv_content | Raw contents of the FinOps CSV file. | string | no |

## Outputs

| Name | Description |
|------|-------------|
| approved_partner_configs | Map of partners approved for vending (AppID and Order# match CSV) |
| finops_validation_status | Status for each partner: AppID, Order#, approved (true/false) |
| finops_mismatches | List of partners not approved, with reason. |

## Examples

See the [examples/validation](./examples/validation) directory for complete working examples.

## Requirements

- Terraform >= 1.1.0
- FinOps CSV file with properly formatted AppID and Order columns

## License

PGE - Internal Use Only

<!-- BEGIN_TF_DOCS -->
# FinOps Validation module
Terraform module which validates partner configurations against FinOps CSV data

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |

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

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_finops_csv_content"></a> [finops\_csv\_content](#input\_finops\_csv\_content) | Raw contents of the FinOps CSV file. | `string` | `""` | no |
| <a name="input_partner_configs"></a> [partner\_configs](#input\_partner\_configs) | Map of partner configs to validate. Must include subscription\_name, tags.AppID and tags.Order. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_approved_partner_configs"></a> [approved\_partner\_configs](#output\_approved\_partner\_configs) | Map of partners approved for vending (AppID and Order# match CSV) |
| <a name="output_finops_mismatches"></a> [finops\_mismatches](#output\_finops\_mismatches) | List of partners not approved, with reason. |
| <a name="output_finops_validation_status"></a> [finops\_validation\_status](#output\_finops\_validation\_status) | Status for each partner: AppID, Order#, approved (true/false) |


<!-- END_TF_DOCS -->