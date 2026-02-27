# EPIC Standard AWS Deployment Role Pattern (Deployment Only)

This document defines the **minimum AWS requirements** needed for EPIC (Azure DevOps Pipeline) to deploy application code/binaries into an AWS account.

Infrastructure (S3, EC2, Beanstalk, etc.) is assumed to already exist.

---

# 1. Role Naming Convention

Use a consistent naming strategy across AWS accounts.

## Single-Application Per Account

```
EPIC-Deployment-Role
```

Optional environment-specific naming:

```
EPIC-Deployment-Role-Dev
EPIC-Deployment-Role-Test
EPIC-Deployment-Role-Prod
```

---

## Multiple Applications Per Account

Use one role per application:

```
EPIC-AppA-Deployment-Role
EPIC-AppB-Deployment-Role
EPIC-AppC-Deployment-Role
```

Optional environment-specific naming:

```
EPIC-AppA-Deployment-Role-Dev
EPIC-AppA-Deployment-Role-Prod
```

This provides application-level isolation within a shared AWS account.

---

# 2. OIDC Provider (One-Time Per Account)

Each AWS account must have an Azure DevOps OIDC provider configured.

Provider URL:

```
https://vstoken.dev.azure.com/<ADO_ORG>
```

Audience:

```
api://AzureADTokenExchange
```

This is created once per AWS account.

---

# 3. Trust Policy Options

Replace:

- `<ACCOUNT_ID>`
- `<ADO_ORG>`
- `<PROJECT_NAME>`
- `<REPO_NAME>`

---

## Option A – Single Application Per Account

Restrict the role to a single repository.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/vstoken.dev.azure.com/<ADO_ORG>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "vstoken.dev.azure.com/<ADO_ORG>:aud": "api://AzureADTokenExchange"
        },
        "StringLike": {
          "vstoken.dev.azure.com/<ADO_ORG>:sub": "repo:<PROJECT_NAME>/<REPO_NAME>:*"
        }
      }
    }
  ]
}
```

This allows only the specified repository to assume the role.

---

## Option B – Multiple Applications Per Account (Single Shared Role)

Allow multiple repositories to assume the same role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/vstoken.dev.azure.com/<ADO_ORG>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "vstoken.dev.azure.com/<ADO_ORG>:aud": "api://AzureADTokenExchange"
        },
        "StringLike": {
          "vstoken.dev.azure.com/<ADO_ORG>:sub": [
            "repo:<PROJECT_NAME>/AppA:*",
            "repo:<PROJECT_NAME>/AppB:*",
            "repo:<PROJECT_NAME>/AppC:*"
          ]
        }
      }
    }
  ]
}
```

This allows multiple application repositories to deploy into the same AWS account using a shared role.

---

# 4. EPIC Deployment Permissions Policy

Create a policy such as:

```
EPIC-Deployment-Policy
```

Attach it to the deployment role.

Below is a baseline example supporting:

- S3 static deployments
- EC2 deployments via SSM
- Elastic Beanstalk updates

Adjust resource ARNs as needed.

```json
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-app-*",
        "arn:aws:s3:::my-app-*/*"
      ]
    },

    {
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:ListCommandInvocations",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "elasticbeanstalk:UpdateEnvironment",
        "elasticbeanstalk:CreateApplicationVersion"
      ],
      "Resource": "*"
    }

  ]
}
```

Permissions may be separated per application if tighter control is required.

---

# 5. EPIC Pipeline Behavior

During deployment, EPIC:

1. Retrieves OIDC token from Azure DevOps
2. Assumes the deployment role
3. Executes AWS CLI commands

Example:

```bash
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/EPIC-Deployment-Role \
  --role-session-name epic-deploy \
  --web-identity-token $SYSTEM_OIDCTOKEN
```

After assuming the role, EPIC performs:

- `aws s3 sync`
- `aws ssm send-command`
- `aws elasticbeanstalk update-environment`
- or other deployment commands

No access keys required.
No stored secrets required.

---

# 6. Summary

For deployment-only integration with EPIC, each AWS account requires:

- OIDC Provider (configured once)
- Deployment Role (single-app or multi-app model)
- Attached Deployment Permissions Policy

Infrastructure must already exist.

This defines the complete deployment contract between EPIC and AWS.

