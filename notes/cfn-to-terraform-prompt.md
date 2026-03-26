Convert a CloudFormation project to Terraform using PG&E's Terraform module standards.

## Inputs

### 1. CloudFormation Source
Project: $ARGUMENTS

Find all CloudFormation template files (.yml, .yaml, .json, .template) in the $ARGUMENTS project directory by searching for files containing `AWSTemplateFormatVersion`. Exclude `node_modules/`, `vendor/`, and `.terraform/` directories. Read every template file completely.

### 2. Complexity Data
Read the combined report CSV at ccoe-cfn-terraform-migration/cfn-combined-report.csv. Find the row where repo_name matches `$ARGUMENTS`. From that row, extract:
- **resource_types** — the pipe-delimited list of AWS resource types (e.g. AWS::S3::Bucket|AWS::IAM::Role|AWS::Lambda::Function). This tells you exactly what AWS services are involved.
- **total_resources** — how many resource declarations to convert
- **nested_stacks, cross_stack_refs, custom_resources, sam_transforms** — complexity flags that affect the conversion approach
- **has_terraform** — whether existing .tf files need to be reconciled
- **aws_account_ids** — which AWS accounts are referenced

### 3. PG&E Terraform Module Examples (Target Standard)
The PG&E Terraform module library is at pge-terraform-modules/aws/modules/. Map the resource_types from the CSV row to PG&E module names. Common mappings:

| AWS Resource Type Pattern | PG&E Module Directory |
|---|---|
| AWS::S3::* | s3 |
| AWS::IAM::* | iam |
| AWS::Lambda::* | lambda |
| AWS::EC2::SecurityGroup | security-group |
| AWS::EC2::Instance | ec2 |
| AWS::EC2::* (VPC/Subnet/etc) | vpc |
| AWS::RDS::* | rds |
| AWS::DynamoDB::* | dynamodb |
| AWS::ECS::* | ecs |
| AWS::EKS::* | eks |
| AWS::ElasticLoadBalancing* | alb or nlb |
| AWS::CloudWatch::* | cloudwatch |
| AWS::SSM::Parameter | ssm |
| AWS::FIS::* | fis |
| AWS::KMS::* | kms |
| AWS::SNS::* | sns |
| AWS::SQS::* | sqs |
| AWS::CloudFront::* | cloudfront |
| AWS::WAF* | waf-v2 |
| AWS::Serverless::Function | lambda (SAM expands to multiple resources) |

For each matching PG&E module, read:
- Root-level variables.tf and main.tf (to understand the module interface)
- examples/ directory (to see the PG&E calling pattern, file layout, tagging, and variable conventions)

## Conversion Rules

1. **Use PG&E modules from TFC Registry** — source = "app.terraform.io/pgetech/<module>/aws". Use native aws_ resources only when no PG&E module exists for that resource type.
2. **Mandatory PG&E tagging** — every resource must use the pgetech/tags/aws module (v0.1.2) with AppID, Environment, DataClassification, CRIS, Notify, Owner, Compliance, Order.
3. **Follow the PG&E file layout**:
   - terraform.tf — provider config with assume_role
   - variables.tf — PG&E tag variables + project-specific variables
   - main.tf — locals, tags module, then all resources/modules
   - outputs.tf — key outputs
   - terraform.auto.tfvars — populate with values from the CFN parameter defaults
4. **Carry over all CFN parameter defaults** to terraform.auto.tfvars.
5. **Extract inline code** (Lambda functions, etc.) to separate files under templates/.
6. **Extract policies** (S3 bucket policies, IAM policies, etc.) to JSON template files under templates/ and use templatefile().
7. **Do NOT use EPIC conventions** — no .pipeline/epic.json, no epic-pipeline-modules, no EPIC backend config.

## Output

Create the .infra/ directory in the $ARGUMENTS project with all Terraform files. Also create a README.md in .infra/ that documents:
- What was converted (resource mapping table: CFN resource → Terraform resource → PG&E module)
- What was NOT converted and why
- File layout
- Configuration values and their sources
- Design decisions

After creating the files, run `terraform fmt` to verify formatting.
