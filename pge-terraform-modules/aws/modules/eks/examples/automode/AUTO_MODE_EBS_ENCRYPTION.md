# Auto Mode EBS Encryption with Customer Managed Keys

Use customer-managed KMS keys (CMK) for EKS Auto Mode EBS volume encryption instead of AWS-managed keys.

## Quick Setup

### 1. Get KMS Key ARN

After deploying your EKS cluster, retrieve the KMS key ARN:

```bash
terraform output kms_key_arn
```

This key is automatically created by the module with all required permissions when you specify `kms_role` and omit `aws_kms_key_arn`.

### 2. Create NodeClass with CMK

Add the KMS key to your NodeClass:

```yaml
apiVersion: eks.amazonaws.com/v1
kind: NodeClass
metadata:
  name: custom-nodeclass
spec:
  role: "noderole-<generated-suffix>"
  subnetSelectorTerms:
    - tags:
        kubernetes.io/role/internal-elb: "1"
  securityGroupSelectorTerms:
    - tags:
        Name: "eks-cluster-sg-*"
  ephemeralStorage:
    size: "160Gi"
    kmsKeyID: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"  # From step 1
```

### 3. Create NodePool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: custom-nodepool
spec:
  template:
    spec:
      nodeClassRef:
        group: eks.amazonaws.com
        kind: NodeClass
        name: custom-nodeclass
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
```

### 4. Deploy via ArgoCD

See [AUTO_MODE_NODE_CLASSES.md](AUTO_MODE_NODE_CLASSES.md#3-deploy-via-argocd) for ArgoCD setup.

Working example: [karpenter-examples/](karpenter-examples/)

## Using an Existing KMS Key

If you're providing your own KMS key (via `aws_kms_key_arn` in Terraform), add these policy statements to your key:

```json
{
  "Sid": "AllowEKSAutoModeCreateGrants",
  "Effect": "Allow",
  "Principal": {
    "AWS": [
      "arn:aws:iam::<account-id>:role/<cluster-name>-cluster",
      "arn:aws:iam::<account-id>:role/noderole-<suffix>"
    ]
  },
  "Action": "kms:CreateGrant",
  "Resource": "*",
  "Condition": {
    "Bool": {
      "kms:GrantIsForAWSResource": "true"
    }
  }
},
{
  "Sid": "AllowEKSAutoModeDirectAccess",
  "Effect": "Allow",
  "Principal": {
    "AWS": [
      "arn:aws:iam::<account-id>:role/<cluster-name>-cluster",
      "arn:aws:iam::<account-id>:role/noderole-<suffix>"
    ]
  },
  "Action": [
    "kms:Decrypt",
    "kms:DescribeKey",
    "kms:Encrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*"
  ],
  "Resource": "*"
}
```

Replace `<account-id>`, `<cluster-name>`, and `<suffix>` with your values. The permissions are split into two statements because Auto Mode needs direct KMS access without the condition.

## KMS Key Formats

The `kmsKeyID` field accepts any of these formats:

- Key ID: `1a2b3c4d-5e6f-1a2b-3c4d-5e6f1a2b3c4d`
- Key ARN: `arn:aws:kms:us-west-2:111122223333:key/1a2b3c4d-5e6f-1a2b-3c4d-5e6f1a2b3c4d`
- Alias name: `alias/eks-auto-mode-key`
- Alias ARN: `arn:aws:kms:us-west-2:111122223333:alias/eks-auto-mode-key`

## Important Notes

- Default node pools (`general-purpose` and `system`) use AWS-managed keys and cannot be configured with CMK
- To use CMK, create custom NodePools with custom NodeClasses as shown above
- The same KMS key can be used for both cluster encryption (etcd/secrets) and EBS encryption
- When the module creates the key, IAM permissions are automatically configured

## Related Documentation

- [AUTO_MODE_NODE_CLASSES.md](AUTO_MODE_NODE_CLASSES.md) - Complete NodeClass guide including access entry requirements
