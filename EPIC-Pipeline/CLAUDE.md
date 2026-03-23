# EPIC-Pipeline — Claude Context

## What This Is

**EPIC-Pipeline** is an enterprise Azure DevOps (ADO) CI/CD framework used at PG&E. Applications define their intent in `.pipeline/epic.json`; EPIC handles execution. It is template-based, data-driven, and designed for programmatic orchestration — not manual runs.

- GitHub org: `pgetech`
- Pipeline ID (engine): `194`
- Variable group: `GV-account-access` (contains `GITHUB_PAT`, AWS service connection)

---

## Architecture

```
epic-orchestrator.yml   ← REST entry point: reads epic.json .app section, invokes engine
epic-engine.yml         ← Control plane: conditional stages, dependency ordering
common/download.yml     ← Clones app repo from GitHub
build/main.yml          ← Build dispatcher → routes to build/{appType}/main.yml
test/main.yml           ← Test dispatcher → routes to test/{unitTestTool}/main.yml
scan/main.yml           ← Scan dispatcher → routes to scan/{scanTool}/*
infra/main.yml          ← Terraform lifecycle (init, plan, apply, destroy)
deploy/main.yml         ← Deploy dispatcher → routes to deploy/{appType}/main.yml
```

### Stage execution order

```
Download
├── Build             (if build=true)
├── UnitTest          (if unitTestTool is set)
├── Scan              (if scanTool is set)
├── DeployInfra       (if terraformAction != 'none')
└── Deploy            (if build=true && deploy=true)
    └── IntegrationTest  (if integrationTestTool is set)
```

### Artifacts

| Artifact | Published By | Consumed By |
|----------|-------------|-------------|
| `epic-app` | Download | Build, Test, Scan, Infra, Deploy |
| `epic-build` | Build | Deploy, Scan |
| `epic-unit-tests` | Test | Scan |
| `terraform-outputs` | DeployInfra | Deploy |

---

## Supported appTypes

| `appType` | Build | Deploy |
|-----------|-------|--------|
| `angular` | npm build | S3 + CloudFront |
| `html` | file copy | S3 + CloudFront |
| `python` | pip/venv/wheel/egg/sdist | EC2 via SSM |
| `java` | Maven or Gradle | EC2 via SSM |
| `dotnet` | dotnet CLI | EC2 via SSM |
| `dotnet_framework` | MSBuild | EC2 via SSM |
| `ami` | EC2 Image Builder (new) | SSM label + SSM config/test docs (new) |

---

## AMI appType

### What it does

Replaces AWS CodePipeline for AMI-building projects. EPIC triggers pre-existing EC2 Image Builder pipelines, polls for completion, writes AMI IDs to SSM, and optionally runs SSM config/test documents against pre-existing instances.

### Key constraint: EPIC never calls Terraform Cloud

All infrastructure (Image Builder pipelines, KMS keys, EC2 instances, SSM documents, IAM roles) is managed outside of EPIC. EPIC only orchestrates build and deploy actions.

### Files

- `build/ami/main.yml` — Build steps (reads cloud config, triggers Image Builder, polls, writes SSM, produces manifest)
- `deploy/ami/main.yml` — Deploy steps (publishes AMIs via SSM labels, runs config/test SSM documents)

### AMI build flow (`build/ami/main.yml`)

1. **Read cloud config** — parses AMI fields from `.pipeline/epic.json` cloud section
2. **Trigger Image Builder** — `aws imagebuilder start-image-pipeline-execution` for each component
3. **Poll for completion** — 60s interval, 2hr timeout, checks AVAILABLE/FAILED
4. **Write to SSM** — `aws ssm put-parameter` + `label-parameter-version` with LATEST label
5. **Prepare manifest** — writes `ami-manifest.json` to `.build/` for the deploy stage

### AMI deploy flow (`deploy/ami/main.yml`)

1. **Read manifest & cloud config** — parses build artifact + `.pipeline/epic.json` cloud section
2. **Publish AMIs** — applies environment label (dev/test/prod) to LATEST SSM parameter version
3. **Wait for instances** — resolves EC2s by Name tag, waits for status OK + SSM agent *(conditional)*
4. **Run config docs** — sends SSM config documents per component *(conditional)*
5. **Wait for config** — polls until all commands succeed *(conditional)*
6. **Run test docs** — sends SSM test documents per component *(conditional)*
7. **Wait for tests** — polls until all tests pass *(conditional)*
8. **Summary** — prints what was built and published

### AMI cloud config (in `.pipeline/epic.json`)

AMI-specific fields live in the `cloud` section alongside the standard AWS fields:

```json
{
  "app": {
    "appName": "gis-enterprise-ami",
    "appType": "ami"
  },
  "cloud": {
    "awsAccountId": "...",
    "awsRegion": "us-west-2",
    "components": ["webadapter", "portal", "datastore", "server"],
    "imageBuilderPipelinePrefix": "ami-factory",
    "ssmParameterPrefix": "/ami_factory",
    "configDocPrefix": "ConfigDoc",
    "testDocPrefix": "TestDoc",
    "componentDocSuffixes": {
      "webadapter": "arcgiswebadaptor",
      "portal": "arcgisportal",
      "datastore": "arcgisdatastore",
      "server": "arcgisserver"
    },
    "instanceTags": {
      "webadapter": "sor-11-5-arcgis-webadaptor-sandbox",
      "server":     "sor-11-5-arcgis-hosting-sandbox",
      "datastore":  "sor-11-5-arcgis-datastore-sandbox",
      "portal":     "sor-11-5-arcgis-portal-sandbox"
    }
  }
}
```

### Component-to-SSM-document suffix mapping

SSM document names are constructed as `{prefix}-{suffix}`. The suffix defaults to the component name, but can be overridden via the optional `componentDocSuffixes` map in the cloud config. This removes hardcoded ArcGIS-specific naming from EPIC and makes the pattern reusable for any AMI project.

```json
"componentDocSuffixes": {
  "webadapter": "arcgiswebadaptor",
  "portal": "arcgisportal",
  "datastore": "arcgisdatastore",
  "server": "arcgisserver"
}
```

If `componentDocSuffixes` is omitted, the raw component name is used as the suffix (e.g., `ConfigDoc-webadapter`).

---

## Related Project: gis-enterprise-ami

Located at `../gis-enterprise-ami/`. This is the AMI project that EPIC's `ami` appType supports.

### What EPIC replaced

The legacy orchestration layer has been removed:
- AWS CodePipeline V2 (5 stages: Source, PrepareParameters, Build, Approval, Publish)
- AWS Step Functions state machine (parallel Image Builder orchestration)
- 5 Lambda functions: `input_preparer`, `ami_writer`, `tfc_runner`, `config_manager`, `ami_publisher`
- EventBridge triggers, pipeline input JSON files
- KMS keys for CodePipeline artifacts, Lambda env, SNS

### What stays in AWS (not EPIC's concern)

- EC2 Image Builder pipelines, recipes, components, infrastructure configs (`ami-pipeline/image_builder.tf`, `ami-pipeline/modules/`)
- KMS keys for AMIs (cross-account sharing) and CloudWatch logs
- SSM parameters (`/ami_factory/{component}/ami`) and documents (ConfigDoc/TestDoc)
- S3 buckets for Image Builder logs and install scripts
- Image Builder IAM role and security group
- Installation scripts in `ami-pipeline/arcgis_install_scripts/11.5/`
- Installation/test YAML templates in `ami-pipeline/templates/`

### IAM requirement

`pge-epic-deployment-role` needs `imagebuilder:StartImagePipelineExecution`, `imagebuilder:GetImage`, `imagebuilder:GetImagePipeline`, and `imagebuilder:ListImagePipelineImages`. These are provisioned in `EPIC AWS Resources/Deploy Role/main.tf` under the `pge-epic-ami-deployment` policy. All other permissions (SSM, EC2, KMS) are covered by existing policies.

### Key paths in gis-enterprise-ami

- `arcgis-enterprise-ami/ami-pipeline/image_builder.tf` — Image Builder pipeline definitions (stays)
- `arcgis-enterprise-ami/ami-pipeline/modules/` — Reusable Image Builder module (stays)
- `arcgis-enterprise-ami/ami-pipeline/templates/` — Component installer/test YAML templates (stays)
- `arcgis-enterprise-ami/ami-pipeline/arcgis_install_scripts/` — Installation configs (stays)
- `arcgis-enterprise-ssm-config/` — SSM config/test documents (stays)
- `arcgis-enterprise-ami/ami-sandbox/` — Manual testing environment (stays)
- `.pipeline/epic.json` — EPIC contract with AMI cloud config

---

## Patterns and Conventions

### AWS credential flow (all deploy/build steps)

Every `AWSShellScript@1` task follows this pattern:
1. Base credentials from ADO `AWS` service connection
2. `aws sts assume-role` into `arn:aws:iam::{awsAccountId}:role/pge-epic-deployment-role`
3. Export temporary credentials as environment variables

### Template routing

Dispatchers route by parameter value using ADO compile-time conditionals:
```yaml
- ${{ if eq(parameters.appType, 'ami') }}:
  - template: ami/main.yml
    parameters:
      ${{ insert }}: ${{ parameters }}
```

### Build output convention

All build types produce a `.build/` directory. The parent `build/main.yml` validates it exists and publishes it as `epic-build`.

### Agent pools

- `ubuntu-latest` — default for everything including AMI
- `windows-latest` — .NET Framework without SonarQube
- `EPIC - Self-hosted` — .NET with SonarQube
