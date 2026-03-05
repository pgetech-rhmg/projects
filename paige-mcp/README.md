# Terraform Knowledge Base Builder

Crawls PG&E's `pge-terraform-modules` Github repo and builds a structured knowledge base from AWS module examples.

## Structure

Crawls `aws/modules/*/examples/*` folders and extracts:
- All `.tf` files (Terraform code)
- All `.json` files (policies, configs)
- `README.md` (documentation)

Output is a JSON knowledge base with complete file contents for each example.

## Usage

### Build Knowledge Base

```bash
# Build in current directory
python -m terraform_kb build

# Build to specific path
python -m terraform_kb build /path/to/output.json
```

### View Stats

```bash
python -m terraform_kb stats
python -m terraform_kb stats /path/to/kb.json
```

## Output Format

```json
{
  "generated_at": "2026-03-04T19:00:00Z",
  "source_url": "https://github.com/pgetech/pge-terraform-modules.git",
  "total_modules": 25,
  "total_examples": 50,
  "modules": {
    "s3": {
      "name": "s3",
      "examples": [
        {
          "name": "s3_static_website",
          "module_name": "s3",
          "terraform_files": {
            "main.tf": "...",
            "variables.tf": "...",
            "outputs.tf": "..."
          },
          "json_files": {
            "s3_bucket_user_policy.json": "..."
          },
          "readme": "..."
        }
      ]
    }
  }
}
```

## Integration with PAIGE API

The knowledge base structure supports PAIGE's CloudFormation → Terraform conversion:

1. **Service Detection**: Extract AWS services from CFN template (e.g., `AWS::S3::Bucket` → `s3`)
2. **Module Lookup**: Query knowledge base by module name (`kb.modules["s3"]`)
3. **Example Retrieval**: Get all examples for that service
4. **Standards Injection**: Pass example content (README + .tf files) into conversion prompt

This gives the AI complete, working examples of PG&E's Terraform patterns for each AWS service.
