# SSM Documents

This directory contains AWS Systems Manager (SSM) documents for supporting HA/DR testing operations.

## Available Documents

### discover-sql-dag-primary.yaml

Discovers which EC2 instance is currently serving as the primary replica in a SQL Server Database Availability Group (DAG).

**Purpose:** Identify the active SQL Server node before running AZ failure tests

**Parameters:**
- `InstanceIds` (StringList, Required): List of EC2 instance IDs that are part of the SQL Server DAG
- `AvailabilityGroupName` (String, Optional): Name of the SQL Server Availability Group to query

**Output:**
- SQL Server Availability Group status for each replica
- Replica role (PRIMARY or SECONDARY)
- Operational state and synchronization health
- Windows Failover Cluster ownership information
- EC2 instance ID and Availability Zone of the primary replica

**Prerequisites:**
1. EC2 instances must have SSM Agent installed and configured
2. SQL Server PowerShell module must be installed on target instances
3. IAM instance profile with SSM permissions
4. SQL Server instances must be configured with DAG

**Usage:**

```bash
# Create the SSM document
aws ssm create-document \
  --name "OIH-Discover-SQL-DAG-Primary" \
  --document-type "Command" \
  --document-format YAML \
  --content file://discover-sql-dag-primary.yaml \
  --region us-east-1

# Execute the document
aws ssm send-command \
  --document-name "OIH-Discover-SQL-DAG-Primary" \
  --instance-ids "i-1234567890abcdef0" "i-0987654321fedcba0" \
  --parameters "AvailabilityGroupName=OIH_AG" \
  --region us-east-1

# View command results
aws ssm get-command-invocation \
  --command-id COMMAND_ID \
  --instance-id INSTANCE_ID \
  --region us-east-1
```

**Example Output:**

```
=== SQL Server DAG Status ===
Local Server: OIH-SQL-01

Availability Group: OIH_AG
Replica Server: OIH-SQL-01
Role: PRIMARY
Operational State: ONLINE
Connected State: CONNECTED
Sync Health: HEALTHY
---
*** THIS SERVER IS THE PRIMARY REPLICA ***
Primary Instance ID: i-1234567890abcdef0
Primary Availability Zone: us-east-1a

=== Windows Failover Cluster Status ===
Cluster Group: OIH_AG
Owner Node: OIH-SQL-01
State: Online
---
```

**Use Case:**

Before running an FIS experiment to stop instances in an AZ, run this document to:
1. Identify which instance is the primary replica
2. Determine which AZ hosts the primary
3. Decide whether to target the primary AZ (test failover) or secondary AZ (ensure primary stability)

**Integration with FIS Experiments:**

```bash
# 1. Discover primary replica
COMMAND_ID=$(aws ssm send-command \
  --document-name "OIH-Discover-SQL-DAG-Primary" \
  --instance-ids "i-instance1" "i-instance2" \
  --query 'Command.CommandId' \
  --output text)

# 2. Wait for completion and parse results
# (Parse output to determine primary AZ)

# 3. Update FIS template with target AZ
# 4. Run FIS experiment
aws fis start-experiment --experiment-template-id EXT123...

# 5. Re-run discovery to validate failover
aws ssm send-command \
  --document-name "OIH-Discover-SQL-DAG-Primary" \
  --instance-ids "i-instance1" "i-instance2"
```

## Customization Notes

### SQL Server Instance Names

If using a named SQL Server instance (not the default instance), modify the script:

```powershell
$instanceName = "YOUR_INSTANCE_NAME"  # e.g., "SQL2019"
```

### Authentication

The script uses Windows Authentication by default. If SQL authentication is required, modify the `Invoke-Sqlcmd` calls:

```powershell
Invoke-Sqlcmd -ServerInstance $fullServerName -Query $query -Username "sa" -Password $password
```

### Additional Metadata

To capture more AWS metadata, add to the script:

```powershell
$privateIp = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/local-ipv4
$subnetId = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/subnet-id
```

## Required IAM Permissions

The EC2 instance profile needs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2messages:GetMessages"
      ],
      "Resource": "*"
    }
  ]
}
```
