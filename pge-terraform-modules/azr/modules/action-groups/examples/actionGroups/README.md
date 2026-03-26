# Action Groups Module Examples

This example demonstrates various configurations for Azure Monitor Action Groups.

## Features

- Multiple action groups with different purposes
- Email notification receivers
- Regional deployments
- Environment-specific configurations (Production, Development, Regional)

## What Gets Created

### Production Environment
- **2 action groups**
  - Operations team action group with 2 email recipients
  - Security team action group with 2 email recipients

### Development Environment
- **1 action group**
  - Development alerts with 1 email recipient

### Regional Environment
- **2 action groups**
  - West US operations action group
  - East US operations action group

## Usage

1. Update the variables in `main.tf` to match your environment:
   ```hcl
   action_groups = [
     {
       name                = "your-actiongroup-name"
       short_name          = "short-name"  # Max 12 characters
       resource_group_name = "your-rg"
       location            = "global"
       enabled             = true
       email_addresses     = ["email@example.com"]
     }
   ]
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Patterns

### Pattern 1: Operations Team Action Group
```hcl
{
  name                = "ops-actiongroup"
  short_name          = "ops"
  resource_group_name = "rg-monitoring"
  email_addresses     = ["ops@example.com", "oncall@example.com"]
}
```

### Pattern 2: Security Team Action Group
```hcl
{
  name                = "security-actiongroup"
  short_name          = "security"
  resource_group_name = "rg-monitoring"
  email_addresses     = ["security@example.com", "soc@example.com"]
}
```

### Pattern 3: Regional Action Groups
```hcl
{
  name                = "westus-ops-actiongroup"
  short_name          = "westus-ops"
  resource_group_name = "rg-monitoring-westus"
  email_addresses     = ["westus-ops@example.com"]
}
```

## Important Notes

- **short_name** must be 12 characters or less
- **location** is typically "global" for action groups
- At least one email address is required per action group
- Action groups can be referenced by other modules using the output `action_group_ids`

## Using Action Groups with Other Modules

After creating action groups, reference them in alert modules:

```hcl
module "appgateway_alerts" {
  source = "../../metricAlerts/appgateway"
  
  action_group = module.action_groups_production.action_group_names[0]
  action_group_resource_group_name = "rg-monitoring-prod"
  # ... other variables
}
```

## Prerequisites

- Azure subscription
- Resource group(s) for action groups
- Valid email addresses for recipients
- Appropriate Azure permissions

## Clean Up

```bash
terraform destroy
```

This will remove all action groups. Note that any alerts using these action groups will need to be updated first.
