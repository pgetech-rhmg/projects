# AMI Factory Infrastructure

Terraform-based infrastructure for building and distributing ArcGIS AMIs across multiple AWS accounts.

## Architecture

This factory builds AMIs for 4 ArcGIS components:
- Web Adapter
- Portal
- DataStore
- Server

Each component uses a shared Image Builder module with component-specific installation and test scripts.

## Prerequisites

1. KMS keys must exist in SSM Parameter Store at:
   - `/webadapter/kms/keyarn`
   - `/portal/kms/keyarn`
   - `/datastore/kms/keyarn`
   - `/server/kms/keyarn`

2. Source S3 bucket containing ArcGIS installation files organized by component and version

## Cross-Account AMI Sharing with KMS Encryption

### Approach
The AMIs are encrypted with KMS keys in the source account. For cross-account sharing to work:

1. **KMS Key Policy** - The KMS key in the source account must grant the target accounts permission to use it
2. **AMI Launch Permissions** - The AMI is shared with target account IDs via `launch_permission`
3. **Target Account Access** - Target accounts can launch instances from the shared AMI using the source account's KMS key

### KMS Key Policy Requirements

Add this statement to each KMS key policy (replace `TARGET_ACCOUNT_ID`):

```json
{
  "Sid": "Allow target account to use the key for AMI",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::TARGET_ACCOUNT_ID:root"
  },
  "Action": [
    "kms:Decrypt",
    "kms:DescribeKey",
    "kms:CreateGrant"
  ],
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "kms:ViaService": [
        "ec2.REGION.amazonaws.com"
      ]
    }
  }
}
```

### Alternative: Target Account Keys
If you prefer target accounts to use their own KMS keys:
1. Target accounts must copy the AMI to their account
2. During copy, re-encrypt with their own KMS key
3. This creates a separate AMI in each target account

The current implementation uses the shared key approach for simplicity.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and configure:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update values in `terraform.tfvars`:
   - Set your environment name
   - Configure source bucket name
   - Add target account IDs for AMI sharing
   - Set ArcGIS component versions

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Structure

```
.
├── main.tf                          # Root module
├── variables.tf                     # Input variables
├── outputs.tf                       # Outputs
├── terraform.tfvars.example         # Example configuration
├── modules/
│   └── image-builder-pipeline/      # Reusable Image Builder module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── templates/                       # Component YAML templates
    ├── webadapter_installer.yaml.tpl
    ├── webadapter_test.yaml.tpl
    ├── portal_installer.yaml.tpl
    ├── portal_test.yaml.tpl
    ├── datastore_installer.yaml.tpl
    ├── datastore_test.yaml.tpl
    ├── server_installer.yaml.tpl
    └── server_test.yaml.tpl
```

## Customizing Installation Scripts

The YAML template files in `templates/` are stubs. Replace the TODO sections with actual:
- Installation commands for each ArcGIS component
- Test commands to verify successful installation
- Any component-specific configuration

Templates support variable substitution:
- `${source_bucket}` - S3 bucket containing installation files
- `${software_version}` - Component version from tfvars

## Outputs

After applying, the following outputs are available:
- `image_builder_pipeline_arns` - ARNs of all 4 pipelines (used by CodePipeline in EPIC 2)
- `log_bucket` - S3 bucket for Image Builder logs

## EPIC 2: Build Pipeline

The build pipeline orchestrates AMI creation, deployment, configuration, and testing.

### Architecture

1. **CodePipeline** - Main orchestration
   - Source: S3 bucket (`pipeline/` prefix)
   - Build: Step Functions state machine
   - Approval: Manual approval gate
   - Publish: Lambda function to apply environment labels

2. **Step Functions State Machine** - Build orchestration
   - Parallel AMI builds using Map state
   - Write AMI IDs to SSM with LATEST label
   - Delete sandbox state parameter
   - Trigger Terraform Cloud workspace
   - Wait for instances to be ready
   - Apply configuration (Chef cookbooks)
   - Run tests
   - All with proper error handling and retries

3. **Lambda Functions**
   - `ami_writer` - Writes AMI IDs to SSM parameters
   - `tfc_runner` - Triggers Terraform Cloud workspace runs
   - `config_manager` - Orchestrates configuration and testing
   - `ami_publisher` - Publishes AMIs with environment labels

4. **EventBridge** - Triggers on AMI publication
   - Monitors SSM parameter label changes
   - Sends notifications to SNS topic
   - Ready for EPIC 3 deployment pipeline integration

### Pipeline Trigger

To trigger the pipeline, upload a file to the assets bucket:

```bash
# Create input file with pipeline ARNs
cat > input.json << EOF
{
  "pipeline_names": [
    {"component": "webadapter", "pipeline_arn": "arn:aws:imagebuilder:..."},
    {"component": "portal", "pipeline_arn": "arn:aws:imagebuilder:..."},
    {"component": "datastore", "pipeline_arn": "arn:aws:imagebuilder:..."},
    {"component": "server", "pipeline_arn": "arn:aws:imagebuilder:..."}
  ]
}
EOF

# Package and upload
zip trigger.zip input.json
aws s3 cp trigger.zip s3://ASSETS_BUCKET/pipeline/trigger.zip
```

### Prerequisites

1. SSM Parameter: `/tfc/api_access_role_arn` - IAM role ARN for TFC API access
2. Secrets Manager: TFC API token secret
3. SSM Documents: `ConfigDoc-{component}` and `TestDoc-{component}` for each component
4. Terraform Cloud workspace configured

### Lambda Dependencies

Each Lambda function has a `requirements.txt`. To package with dependencies:

```bash
cd lambda/ami_writer
pip install -r requirements.txt -t .
cd ../..
```

Or use a Lambda layer for common dependencies (boto3 is included in Lambda runtime).

### Testing

The ConfigManager Lambda expects:
- SSM parameter `/ami_factory/sandbox_state` with JSON:
  ```json
  {
    "instances": [
      {"instance_id": "i-1234567890abcdef0", "component": "webadapter"},
      {"instance_id": "i-0987654321fedcba0", "component": "portal"}
    ]
  }
  ```
- SSM documents named `ConfigDoc-{component}` and `TestDoc-{component}`
