# Auto Mode: Custom NodeClasses

Create custom NodeClasses to configure node infrastructure settings including subnets, security groups, storage, and KMS encryption.

## Quick Start

See working examples in [karpenter/](karpenter/):
- [custom-nodeclass.yaml](karpenter/custom-nodeclass.yaml) - NodeClass with CMK encryption
- [custom-nodepool.yaml](karpenter/custom-nodepool.yaml) - NodePool referencing the NodeClass
- [karpenter.yaml](karpenter/karpenter.yaml) - ArgoCD Application CR
- [test-pod.yaml](karpenter/test-pod.yaml) - Pod using the custom NodePool

## Access Entry Requirement

Custom NodeClasses require an EKS Access Entry for nodes to join the cluster if you are using a custom role for your nodes.
If using the existing node role created by this module (recommended), you don't need to create an access entry.

If you are using a custom role, add this access entry to your Terraform:

```hcl
data "aws_iam_role" "auto_node_custom_role" {
  name = "noderole-custom"  # Your actual role name
}

resource "aws_eks_access_entry" "custom_auto_node" {
  cluster_name  = module.eks.cluster_id
  principal_arn = data.aws_iam_role.auto_node_custom_role.arn
  type         = "EC2"
}

resource "aws_eks_access_policy_association" "auto_node" {
  cluster_name  = module.eks.cluster_id
  principal_arn = data.aws_iam_role.auto_node_custom_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  
  access_scope {
    type = "cluster"
  }
  
  depends_on = [aws_eks_access_entry.custom_auto_node]
}
```

One access entry per IAM role works for all NodeClasses using that role.

## Creating a Custom NodeClass

### 1. Define NodeClass YAML

Minimal example using existing auto node role:

```yaml
apiVersion: eks.amazonaws.com/v1
kind: NodeClass
metadata:
  name: custom-nodeclass
spec:
  role: "noderole-<generated-suffix>"  # Use existing node role from Terraform
  subnetSelectorTerms:
    - tags:
        kubernetes.io/role/internal-elb: "1"
  securityGroupSelectorTerms:
    - tags:
        Name: "eks-cluster-sg-*"  # Match your cluster's security group
  ephemeralStorage:
    size: "160Gi"
    kmsKeyID: "arn:aws:kms:region:account:key/key-id"  # Optional: For CMK encryption
```

For CMK encryption setup, see [AUTO_MODE_EBS_ENCRYPTION.md](AUTO_MODE_EBS_ENCRYPTION.md).

### 2. Create NodePool

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

### 3. Deploy via ArgoCD

Commit your NodeClass and NodePool to Git, then create an ArgoCD Application and commit to Git:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: karpenter
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo.git
    targetRevision: main
    path: manifests/karpenter
  destination:
    server: https://kubernetes.default.svc
    namespace: karpenter
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=true
```

Verify deployment:

```bash
kubectl get nodeclass
kubectl get nodepool
kubectl get nodes
```

### 4. Schedule Workloads

Use node selectors to target your NodePool:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: karpenter-test-pod
spec:
  nodeSelector:
    karpenter.sh/nodepool: custom-nodepool
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
```

## Troubleshooting

### Nodes Not Joining Cluster

Verify Access Entry exists in Terraform:

```bash
terraform state list | grep aws_eks_access_entry
terraform state show aws_eks_access_entry.auto_node
```

### NodeClass Not Found

Verify NodeClass was created:

```bash
kubectl get nodeclass
kubectl describe nodeclass my-nodeclass
```
