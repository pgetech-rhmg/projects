# FIS Experiment Templates

This directory contains AWS Fault Injection Simulator (FIS) experiment templates for testing the High Availability and Disaster Recovery capabilities of the Outage Information Hub (OIH) workload.

## Available Templates

### stop-ec2-instances-by-az.yaml

Stops all EC2 instances in a specified Availability Zone to simulate an AZ failure.

**Target Resources:** EC2 instances
**Action:** `aws:ec2:stop-instances-v2`
**Duration:** 5 minutes (configurable)

**Prerequisites:**
1. FIS IAM role with permissions to stop EC2 instances
2. CloudWatch log group for experiment logs
3. EC2 instances tagged appropriately for targeting

**Configuration Required:**
- Update `Placement.AvailabilityZone` filter with your target AZ
- Replace `ACCOUNT_ID` with your AWS account ID
- Update `roleArn` with your FIS execution role ARN
- Update `logGroupArn` with your CloudWatch log group ARN
- Adjust resource tags to match your environment

**Usage:**

```bash
# Create the experiment template
aws fis create-experiment-template \
  --cli-input-yaml file://stop-ec2-instances-by-az.yaml \
  --region us-east-1

# Start the experiment (requires template-id from creation)
aws fis start-experiment \
  --experiment-template-id EXT_TEMPLATE_ID \
  --region us-east-1

# Monitor experiment status
aws fis get-experiment \
  --id EXPERIMENT_ID \
  --region us-east-1
```

## Creating an FIS IAM Role

Example IAM policy for FIS execution:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StopInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Environment": "QA"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
```

Trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "fis.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Best Practices

1. **Test in QA First:** Always validate experiments in non-production environments
2. **Use Stop Conditions:** Configure CloudWatch alarms as stop conditions to automatically halt experiments if critical metrics are impacted
3. **Tag Resources:** Use consistent tagging for precise targeting
4. **Monitor Logs:** Enable CloudWatch logging for all experiments
5. **Coordinate Testing:** Notify relevant teams before running experiments
6. **Document Results:** Record observations and any issues discovered

## Safety Considerations

- FIS experiments can cause real service disruptions
- Always verify target selection before starting experiments
- Have rollback procedures ready
- Consider using `selectionMode: COUNT` with a small count for initial tests
- Review experiment templates with your team before execution
