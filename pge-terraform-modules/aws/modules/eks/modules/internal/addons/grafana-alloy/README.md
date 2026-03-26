# Grafana Alloy Addon Module

This module provides AWS resources for Grafana Alloy integration with Amazon EKS clusters.

## Overview

**Current Status: Placeholder Module**

This module currently contains placeholder code for potential future AWS integrations with Grafana Alloy. For standard Kubernetes monitoring use cases, Grafana Alloy typically does not require any AWS-specific resources and can operate entirely within the Kubernetes cluster using RBAC permissions.

## When This Module Would Be Needed

This module would become useful if your Grafana Alloy configuration requires:

- **AWS Service Discovery**: Using EC2, ECS, or other AWS services for target discovery
- **AWS Data Destinations**: Sending telemetry data to AWS services like CloudWatch, S3, or Kinesis
- **Cross-Account Access**: Accessing resources in other AWS accounts
- **AWS API Integration**: Any custom integrations requiring AWS API calls

## Current Use Case

For most Kubernetes monitoring scenarios where Alloy:
- Scrapes metrics from Kubernetes pods/services
- Sends data to in-cluster destinations (Prometheus, Loki, Grafana)
- Uses Kubernetes service discovery

**No AWS resources are required.** The Helm chart installation handles all necessary Kubernetes RBAC and service accounts.

## Module Structure

```
grafana-alloy/
├── main.tf          # Placeholder AWS resources (commented out)
├── variables.tf     # Variable definitions
├── outputs.tf       # Output definitions
├── versions.tf      # Provider requirements
└── README.md        # This file
```

## Usage

Currently, this module is safely excluded from the EKS TF module.

## Future Enhancements

When AWS integration is needed, this module will provide:

- IAM roles with appropriate policies for AWS service access
- EKS Pod Identity associations for secure AWS API access
- Any additional AWS resources required for specific Alloy configurations

## Related Documentation

- [Grafana Alloy Documentation](https://grafana.com/docs/alloy/)
- [Grafana Alloy Kubernetes Configuration](https://grafana.com/docs/alloy/latest/tasks/configure/configure-kubernetes/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
