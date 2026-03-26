# FIS Tagging Scripts - Quick Reference

## Which Script Should I Use?

### For EC2 and EBS Experiments

**Use: `scripts/tag-resources-for-fis.sh`**

Tag EC2 instances and EBS volumes for:
- EC2 Stop/Start experiments
- EBS I/O Pause experiments

**Tags applied:**
- EC2 Instances: `FISTarget=True`, `FISDBRole=Primary|Secondary`
- EBS Volumes: `FISTarget=True`, `FISEBSTarget=True`, `FISDBRole=Primary|Secondary`

**Features:**
- Interactive menu-driven interface
- Tag instances and automatically propagate role to attached volumes
- Preview resources before tagging
- View currently tagged resources by role
- Remove tags safely
- Prevents orphaned volumes (ensures FISDBRole matches instance)

**Example workflow:**
```bash
./scripts/tag-resources-for-fis.sh

# Menu options:
# 1) Tag instance as Primary → also tags its volumes
# 2) Tag instance as Secondary → also tags its volumes
# 3) Show all Primary instances
# 4) Show all Secondary instances
# 8) Show all FIS-tagged volumes
```

---

### For Network Disruption / AZ Failure Experiments

**Use: `scripts/tag-subnets-for-fis.sh`**

Tag subnets for:
- Network Disruption experiments (complete AZ failure simulation)
- Subnet-level isolation testing

**Tags applied:**
- Subnets: `FISTarget=True`, `FISAZRole=Primary|Secondary|TestAZ`

**Features:**
- Tag individual subnets or all subnets in an AZ at once
- Preview what resources will be affected (EC2, Lambda, RDS, Load Balancers)
- Impact analysis showing ENI counts and resource types
- AZ-aware operations
- Warnings about disruption impact before tagging
- List available AZs with subnet counts

**Example workflow:**
```bash
./scripts/tag-subnets-for-fis.sh

# Menu options:
# 2) Tag all subnets in an AZ as Primary
# 3) Tag all subnets in an AZ as Secondary
# 4) Tag all subnets in an AZ as TestAZ (for isolated testing)
# 9) Show impact summary (what will be disrupted)
```

---

## Tag Hierarchy and Experiment Types

### Component-Level Testing (EC2/EBS)

```
FIS Experiment: EC2 Stop
├─ Targets: EC2 Instances
├─ Required Tags: FISTarget=True, FISDBRole=Primary|Secondary
└─ Action: aws:ec2:stop-instances

FIS Experiment: EBS I/O Pause
├─ Targets: EBS Volumes
├─ Required Tags: FISTarget=True, FISEBSTarget=True, FISDBRole=Primary|Secondary
└─ Action: aws:ebs:pause-volume-io
```

### AZ-Level Testing (Subnets)

```
FIS Experiment: Network Disruption
├─ Targets: Subnets
├─ Required Tags: FISTarget=True, FISAZRole=Primary|Secondary|TestAZ
├─ Action: aws:network:disrupt-connectivity
└─ Affects: ALL resources in subnet (EC2, Lambda, RDS, LB, etc.)
```

---

## Common Workflows

### Initial Setup: Tag Production OIH Resources

**Step 1: Tag EC2 Instances and EBS Volumes**
```bash
./scripts/tag-resources-for-fis.sh

# For each SQL Server Primary instance:
# Option 1 → Enter instance ID → yes to tag
# Option 6 → Enter same instance ID → yes to tag volumes

# For each SQL Server Secondary instance:
# Option 2 → Enter instance ID → yes to tag
# Option 6 → Enter same instance ID → yes to tag volumes
```

**Step 2: Tag Subnets for AZ Failure Testing**
```bash
./scripts/tag-subnets-for-fis.sh

# Tag Primary AZ subnets (e.g., us-west-2b):
# Option 2 → Enter 'us-west-2b' → yes to tag all subnets

# Tag Secondary AZ subnets (e.g., us-west-2a):
# Option 3 → Enter 'us-west-2a' → yes to tag all subnets

# Review impact:
# Option 9 → Choose Primary or Secondary → See what will be disrupted
```

### Isolated Testing Setup: Tag Test Subnet in AZ-D

**For safe validation before production testing:**
```bash
./scripts/tag-subnets-for-fis.sh

# Tag isolated test subnet:
# Option 4 → Enter 'us-west-2d' → yes to tag

# Verify:
# Option 8 → Show TestAZ subnets
```

### Pre-Experiment Verification

**Before running experiments, verify targeting:**
```bash
# Check EC2/EBS targeting:
./scripts/tag-resources-for-fis.sh
# Option 3 → Show Primary instances
# Option 4 → Show Secondary instances
# Option 8 → Show all FIS-tagged volumes

# Check Subnet targeting:
./scripts/tag-subnets-for-fis.sh
# Option 5 → Show all FIS-tagged subnets
# Option 9 → Show impact summary for Primary/Secondary
```

### Cleanup After Testing

**Remove tags from test resources:**
```bash
# Remove EC2/EBS tags:
./scripts/tag-resources-for-fis.sh
# Option 5 → Remove tags from instance
# Option 9 → Remove tags from volumes attached to instance

# Remove subnet tags:
./scripts/tag-subnets-for-fis.sh
# Option 10 → Remove tags from single subnet
# Option 11 → Remove tags from all subnets in AZ
```

---

## Safety Features

### tag-resources-for-fis.sh

✅ Shows instance/volume details before tagging
✅ Requires explicit "yes" confirmation
✅ Auto-propagates FISDBRole from instance to volumes
✅ Warns if instance not tagged before tagging volumes
✅ Filters to running/stopped instances only (skips terminated)

### tag-subnets-for-fis.sh

✅ Shows subnet details and resource counts before tagging
✅ Displays sample of affected resources (EC2, Lambda, RDS, LB)
✅ Warns about disruption impact before tagging
✅ Shows existing tags and confirms before overwriting
✅ Impact analysis shows exactly what will be disrupted
✅ Requires explicit "yes" confirmation for all operations

---

## Troubleshooting

### Issue: Can't tag EBS volumes

**Symptom**: Script says "Instance does not have FISDBRole tag set"

**Solution**: Tag the EC2 instance first (Options 1 or 2), THEN tag its volumes (Option 6)

---

### Issue: FIS experiment doesn't find any targets

**Symptom**: FIS experiment fails with "No targets found"

**Solution**: Verify tags with "Show" options in the scripts:
```bash
# For EC2/EBS experiments:
./scripts/tag-resources-for-fis.sh → Options 3, 4, 8

# For Network Disruption experiments:
./scripts/tag-subnets-for-fis.sh → Options 5, 6, 7, 8
```

---

### Issue: Wrong resources are tagged

**Symptom**: Accidentally tagged production when meant to tag test

**Solution**: Use the "Remove" options:
```bash
# Remove individual resource tags:
# tag-resources-for-fis.sh → Options 5, 9
# tag-subnets-for-fis.sh → Option 10

# Remove all tags from an AZ:
# tag-subnets-for-fis.sh → Option 11

# Nuclear option (remove ALL subnet tags):
# tag-subnets-for-fis.sh → Option 12 (USE WITH CAUTION)
```

---

## Tag Reference

### EC2 Instance Tags
```
FISTarget: True              # Enables FIS targeting
FISDBRole: Primary           # Role-based targeting (or Secondary)
```

### EBS Volume Tags
```
FISTarget: True              # Enables FIS targeting
FISEBSTarget: True           # Specifically for EBS experiments
FISDBRole: Primary           # Must match attached instance role
```

### Subnet Tags
```
FISTarget: True              # Enables FIS targeting
FISAZRole: Primary           # AZ role (Primary, Secondary, or TestAZ)
```

---

## Summary

| Experiment Type | Script to Use | Resources Tagged |
|-----------------|---------------|------------------|
| EC2 Stop/Start | tag-resources-for-fis.sh | EC2 Instances |
| EBS I/O Pause | tag-resources-for-fis.sh | EC2 Instances + EBS Volumes |
| Network Disruption (AZ Failure) | tag-subnets-for-fis.sh | Subnets |

**Best Practice**: Always use "Show" options to verify targeting before running FIS experiments!
