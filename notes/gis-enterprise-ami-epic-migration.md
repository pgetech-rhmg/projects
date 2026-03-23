# Migrating gis-enterprise-ami to EPIC Pipeline

Step-by-step guide for converting the gis-enterprise-ami project from AWS CodePipeline to EPIC's `ami` appType.

---

## Step 1: Verify `.pipeline/epic.json`

The contract file is already created at `gis-enterprise-ami/.pipeline/epic.json`:

```json
{
  "app": {
    "appName": "gis-enterprise-ami",
    "appType": "ami",
    "codePath": "/"
  },
  "cloud": {
    "awsAccountId": "587401437202",
    "awsRegion": "us-west-2",
    "components": ["webadapter", "portal", "datastore", "server"],
    "imageBuilderPipelinePrefix": "ami-factory",
    "ssmParameterPrefix": "/ami_factory",
    "configDocPrefix": "ConfigDoc",
    "testDocPrefix": "TestDoc",
    "instanceTags": {
      "webadapter": "sor-11-5-arcgis-webadaptor-sandbox",
      "server": "sor-11-5-arcgis-hosting-sandbox",
      "datastore": "sor-11-5-arcgis-datastore-sandbox",
      "portal": "sor-11-5-arcgis-portal-sandbox"
    }
  }
}
```

**Verify before running:**

- `awsAccountId` — confirm `587401437202` is the correct target account
- `components` — confirm all 4 components should build (or adjust to subset)
- `imageBuilderPipelinePrefix` — confirm Image Builder pipelines are named `ami-factory-{component}-{environment}`
- `ssmParameterPrefix` — confirm SSM parameters are at `/ami_factory/{component}/ami`
- `configDocPrefix` / `testDocPrefix` — confirm SSM documents are named `ConfigDoc-{ssmDocSuffix}` and `TestDoc-{ssmDocSuffix}` where the suffix uses the component name mapping:

  | Component | SSM Doc Suffix |
  |-----------|---------------|
  | `webadapter` | `arcgiswebadaptor` |
  | `portal` | `arcgisportal` |
  | `datastore` | `arcgisdatastore` |
  | `server` | `arcgisserver` |

- `instanceTags` — confirm EC2 Name tags match running instances in the target environment

---

## Step 2: Apply IAM permissions

Apply the `pge-epic-deployment-role` in the target account (`587401437202`).

**Action:** Apply the updated Deploy Role Terraform (`EPIC AWS Resources/Deploy Role/`) to the target account if not already done.

---

## Step 3: Verify SSM documents exist

EPIC's deploy stage sends SSM commands using document names constructed as `{configDocPrefix}-{ssmDocSuffix}` and `{testDocPrefix}-{ssmDocSuffix}`.

With the current config, EPIC will look for:

| Document | Purpose |
|----------|---------|
| `ConfigDoc-arcgiswebadaptor` | Configure Web Adaptor |
| `ConfigDoc-arcgisportal` | Configure Portal |
| `ConfigDoc-arcgisdatastore` | Configure DataStore |
| `ConfigDoc-arcgisserver` | Configure Server |
| `TestDoc-arcgiswebadaptor` | Validate Web Adaptor |
| `TestDoc-arcgisportal` | Validate Portal |
| `TestDoc-arcgisdatastore` | Validate DataStore |
| `TestDoc-arcgisserver` | Validate Server |

**Verify:** Confirm these documents exist in the target account. They may be:
- Already created by the existing `ami-pipeline/ssm_documents.tf` (placeholder definitions)
- Managed separately in `arcgis-enterprise-ssm-config/`

If the documents don't exist or the naming doesn't match, either:
- Create/rename the documents in AWS, or
- Update `configDocPrefix` / `testDocPrefix` in `epic.json` to match the actual naming convention

**Note:** If `configDocPrefix` or `testDocPrefix` are omitted or empty in `epic.json`, the config/test steps are skipped entirely. The same applies if `instanceTags` is empty — no instances to target means no config/test execution.

---

## Step 4: Test with a dry run

Trigger EPIC with only the build stage enabled to validate Image Builder integration without deploying:

```
Parameters:
  repo: gis-enterprise-ami
  branch: main (or a feature branch)
  environment: dev
  build: true
  tests: false
  scan: false
  deploy: false
  deployInfra: none
```

**What should happen:**
1. EPIC clones the repo, reads `.pipeline/epic.json`
2. `build/ami/main.yml` reads the `cloud` section
3. Triggers Image Builder for each component (`ami-factory-{component}-dev`)
4. Polls every 60s until all builds complete (up to 2hr timeout)
5. Writes AMI IDs to `/ami_factory/{component}/ami` with `LATEST` label
6. Publishes `ami-manifest.json` as the `epic-build` artifact

**Verify after build:**
- Check SSM parameters: `aws ssm get-parameter --name "/ami_factory/webadapter/ami"` (repeat for each component)
- Each should have a `LATEST` label on the newest version

---

## Step 5: Test the deploy stage

Once build succeeds, run with deploy enabled:

```
Parameters:
  repo: gis-enterprise-ami
  branch: main
  environment: dev
  build: true
  deploy: true
  deployInfra: none
```

**What should happen:**
1. Build stage runs (same as step 4)
2. Deploy stage reads the manifest + cloud config
3. Applies `dev` label to the LATEST SSM parameter versions
4. If `instanceTags` are set: resolves EC2 instances by Name tag, waits for status OK + SSM agent
5. If `configDocPrefix` is set: runs ConfigDoc SSM documents on each instance
6. If `testDocPrefix` is set: runs TestDoc SSM documents on each instance

---

## Step 6: Remove legacy orchestration from gis-enterprise-ami

Once EPIC is working, remove the AWS CodePipeline orchestration layer. These are all in `arcgis-enterprise-ami/ami-pipeline/`:

### Remove these Terraform files:

| File | What it provisions |
|------|--------------------|
| `pipeline.tf` | CodePipeline V2, pipeline artifacts S3 bucket, SNS topic, pipeline IAM role |
| `step_function.tf` | Step Functions state machine, CloudWatch log group |
| `lambdas.tf` | All 5 Lambda function definitions |
| `lambda_iam.tf` | IAM roles for all 5 Lambda functions |
| `lambda_layers.tf` | Powertools + Klayers Lambda layers |
| `eventbridge.tf` | Golden AMI update trigger + publish notification rules |
| `ssm_documents.tf` | Placeholder ConfigDoc/TestDoc definitions (if real ones exist in `arcgis-enterprise-ssm-config/`) |

### Remove these KMS keys from `kms.tf`:

| Key | Reason |
|-----|--------|
| `codepipeline-artifacts` | No more CodePipeline |
| `lambda-env` | No more Lambda functions |
| `sns` | No more SNS notifications (or keep if needed elsewhere) |

**Keep** the `amis` and `cloudwatch-logs` keys — still used by Image Builder.

### Remove these directories:

| Directory | What it contains |
|-----------|-----------------|
| `lambda/` | All 5 Lambda function source code (`input_preparer/`, `ami_writer/`, `tfc_runner/`, `config_manager/`, `ami_publisher/`) |
| `pipeline_inputs/` | Component selection JSONs (`all_components.json`, `*_only.json`, `test_mode_example.json`) |

### Keep these files/directories:

| File/Directory | Why |
|----------------|-----|
| `main.tf` | Data sources (VPC, subnet, KMS lookups), tagging — consumed by Image Builder. Remove any references to deleted pipeline/Lambda/Step Function resources. |
| `image_builder.tf` | EC2 Image Builder pipeline definitions — EPIC triggers these |
| `modules/image-builder-pipeline/` | Reusable Image Builder module |
| `templates/` | Component installer + test YAML templates |
| `arcgis_install_scripts/` | Installation configs uploaded to S3 |
| `kms.tf` (partial) | Keep `amis` and `cloudwatch-logs` keys |
| S3 buckets for Image Builder logs and assets | Referenced by Image Builder infra config |
| Image Builder IAM role + security group | Image Builder instances need these |

---

## Step 7: Clean up `main.tf`

After removing the pipeline/Lambda/Step Function Terraform files, review `main.tf` for dangling references:

- Remove any `locals` or `data` sources that were only used by the deleted resources
- Remove any variables in `variables.tf` that are no longer referenced (e.g., `tfc_api_token_secret`, `test_subnet_id`, `test_instance_type`)
- Run `terraform plan` to verify no errors from removed references

---

## Step 8: Terraform destroy the legacy resources

Before removing the Terraform files, destroy the legacy resources in AWS:

```bash
# Target destroy the orchestration resources (DO NOT destroy Image Builder infra)
terraform destroy \
  -target=aws_codepipeline.ami_pipeline \
  -target=aws_sfn_state_machine.ami_build \
  -target=aws_lambda_function.input_preparer \
  -target=aws_lambda_function.ami_writer \
  -target=aws_lambda_function.tfc_runner \
  -target=aws_lambda_function.config_manager \
  -target=aws_lambda_function.ami_publisher \
  -target=aws_cloudwatch_event_rule.golden_ami_update \
  -target=aws_cloudwatch_event_rule.ami_published
```

**Important:** Use `-target` flags to selectively destroy only the orchestration resources. Do NOT run a blanket `terraform destroy` — that would also remove the Image Builder infrastructure that EPIC depends on.

After the targeted destroy, remove the Terraform files listed in Step 6, then run `terraform plan` to confirm a clean state with only the Image Builder infrastructure remaining.

---

## Summary

| Phase | Action |
|-------|--------|
| **Step 1** | Verify `epic.json` values match AWS resources |
| **Step 2** | Apply updated IAM policy to target account |
| **Step 3** | Verify SSM document names match EPIC's expected naming |
| **Step 4** | Dry run — build only |
| **Step 5** | Full run — build + deploy |
| **Step 6–8** | Remove legacy CodePipeline orchestration |
