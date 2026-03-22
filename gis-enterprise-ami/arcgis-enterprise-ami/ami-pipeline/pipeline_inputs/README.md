# Pipeline Input Files

This directory contains various input configurations for the AMI Factory pipeline.

## Files

- `all_components.json` - Build all 4 components (default)
- `webadapter_only.json` - Build only webadapter
- `portal_only.json` - Build only portal
- `datastore_only.json` - Build only datastore
- `server_only.json` - Build only server
- `test_mode_example.json` - Example input for test mode (same format as all_components.json)

## Test Mode vs Production Mode

The pipeline can run in two modes, controlled by the `test_mode` Terraform variable:

### Production Mode (test_mode = false)
- Executes EC2 Image Builder pipelines to build new AMIs
- Takes 20-30 minutes per component
- Creates fresh AMIs with latest software versions
- Use for actual AMI builds

### Test Mode (test_mode = true)
- Skips Image Builder execution
- Looks up most recent existing AMI for each component
- Completes in seconds instead of minutes
- Useful for testing the pipeline flow without waiting for builds
- Tests Lambda functions, SSM parameter updates, TFC integration, etc.

To enable test mode, set in `terraform.tfvars`:
```hcl
test_mode = true
```

## Usage

### Automatic Trigger (EventBridge)

The pipeline automatically triggers when the `/coe/golden_ami` SSM parameter is updated. It uses the default `input.zip` from the S3 bucket (all components).

### Manual Trigger - All Components

```bash
# Create zip file and upload
cd pipeline_inputs
zip input.zip all_components.json
aws s3 cp input.zip s3://$(tofu output -raw assets_bucket)/pipeline/input.zip
aws codepipeline start-pipeline-execution --name ami-factory-pipeline-dev
```

### Manual Trigger - Single Component

To rebuild only one component:

```bash
# Example: Rebuild only webadapter
cd pipeline_inputs
zip input.zip webadapter_only.json
aws s3 cp input.zip s3://$(tofu output -raw assets_bucket)/pipeline/input.zip
aws codepipeline start-pipeline-execution --name ami-factory-pipeline-dev
```

```bash
# Example: Rebuild only portal
cd pipeline_inputs
zip input.zip portal_only.json
aws s3 cp input.zip s3://$(tofu output -raw assets_bucket)/pipeline/input.zip
aws codepipeline start-pipeline-execution --name ami-factory-pipeline-dev
```

### Manual Trigger - Custom Combination

Create a custom JSON file with any combination:

```json
{
  "components": [
    "webadapter",
    "server"
  ]
}
```

Then zip and upload:

```bash
cd pipeline_inputs
zip input.zip custom_input.json
aws s3 cp input.zip s3://$(tofu output -raw assets_bucket)/pipeline/input.zip
aws codepipeline start-pipeline-execution --name ami-factory-pipeline-dev
```

**Important:** The JSON file inside the zip must be named `input.json` for CodePipeline to extract it correctly. When using the pre-built files, rename them:

```bash
# Correct approach
cp webadapter_only.json input.json
zip input.zip input.json
aws s3 cp input.zip s3://$(tofu output -raw assets_bucket)/pipeline/input.zip
```

## Direct Step Functions Execution

You can also bypass CodePipeline and run Step Functions directly:

```bash
# All components
aws stepfunctions start-execution \
  --state-machine-arn $(tofu output -raw state_machine_arn) \
  --input file://pipeline_inputs/all_components.json \
  --name "manual-all-$(date +%s)"

# Single component
aws stepfunctions start-execution \
  --state-machine-arn $(tofu output -raw state_machine_arn) \
  --input file://pipeline_inputs/webadapter_only.json \
  --name "manual-webadapter-$(date +%s)"
```

## Testing Workflow

Recommended workflow for testing changes:

1. **Enable test mode** in `terraform.tfvars`:
   ```hcl
   test_mode = true
   tfc_dry_run = true
   ```

2. **Deploy infrastructure**:
   ```bash
   tofu apply
   ```

3. **Test the pipeline** with existing AMIs:
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn $(tofu output -raw state_machine_arn) \
     --input file://pipeline_inputs/all_components.json \
     --name "test-run-$(date +%s)"
   ```

4. **Verify** Lambda functions, SSM updates, and TFC integration work correctly

5. **Switch to production mode** when ready:
   ```hcl
   test_mode = false
   tfc_dry_run = false  # When TFC is configured
   ```

## Notes

- The Lambda function converts these to underscores for SSM parameters (e.g., `/ami_factory/webadapter/ami`)
- The Step Functions state machine constructs Image Builder pipeline ARNs automatically
- In test mode, the state machine uses `ec2:DescribeImages` to find the most recent AMI matching the pattern `ami-factory-{component}-{environment}-*`
- Partial builds are useful for:
  - Testing changes to a single component
  - Rebuilding after a failed component build
  - Reducing build time when only one component needs updating
