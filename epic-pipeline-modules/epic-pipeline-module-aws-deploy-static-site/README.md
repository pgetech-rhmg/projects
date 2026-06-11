# epic-pipeline-module-aws-deploy-static-site

## Overview

Terraform module that uploads a built static site (HTML/CSS/JS/assets) to a pre-existing S3 bucket as individually-tracked `aws_s3_object` resources. Intended for use from an application's `.infra/` folder when EPIC's deploy stage is not handling the upload directly, or when an `appType: "infra"` repo needs to publish assets as part of a Terraform apply.

The module does not create the bucket, configure static website hosting, manage CloudFront, or invalidate caches. Those responsibilities belong to upstream infrastructure modules and to EPIC's `deploy/aws/static` stage.

Resolves the source directory using the EPIC workspace layout: `${path.root}/${app_name}/${app_path}`.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_s3_object.website_files` | One object per file under the resolved website root. Content type is inferred from extension (with optional overrides), and changes are detected via `filemd5` etag. |

This module is pure Terraform — it does not shell out to the AWS CLI, does not use `null_resource`, and does not invalidate CloudFront. Plans and applies are deterministic against the contents of the source directory.

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `app_name` | `string` | Application name. Used as the first path segment when resolving the source directory (`${path.root}/${app_name}/${app_path}`). |
| `bucket_name` | `string` | Target S3 bucket name. Must already exist. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `app_path` | `string` | `"/"` | Relative path under the app folder containing the built static site files. |
| `cache_control` | `string` | `null` | Optional `Cache-Control` header applied to every uploaded object. |
| `content_type_overrides` | `map(string)` | `{}` | Map of lowercase file extension → MIME type. Merged over the module's defaults (`html`, `css`, `js`, `json`, `png`, `jpg`, `jpeg`, `svg`, `ico`, `txt`, `map`). Unmatched extensions fall back to `binary/octet-stream`. |

## Outputs

| Name | Description |
|------|-------------|
| `deployed_bucket` | The S3 bucket name that received the assets (echoes `bucket_name`). |
| `file_count` | Number of files uploaded. |

## Usage in a Terraform Project

Typical usage from an application's `.infra/main.tf`. The bucket is created elsewhere (for example by an upstream `aws-s3` module) and its name is passed in.

```hcl
module "deploy_static_site" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-deploy-static-site.git?ref=main"

  app_name    = "my-react-app"
  bucket_name = module.web_bucket.bucket_name

  app_path      = "/dist"
  cache_control = "max-age=3600"

  content_type_overrides = {
    webmanifest = "application/manifest+json"
  }
}
```

With this configuration, the module reads files from `${path.root}/my-react-app/dist` and uploads each one to `module.web_bucket.bucket_name`.

The corresponding `.pipeline/epic.json` entry points the deploy stage at the same bucket (and at the CloudFront distribution that fronts it):

```json
{
  "app": {
    "appName": "my-react-app",
    "appType": "react",
    "codePath": "/"
  },
  "cloud": {
    "awsAccountId": "999999999999",
    "awsRegion": "us-west-2",
    "s3": "pge-epic-my-react-app-web-dev",
    "cloudfront": "X9X9X9XX99XX9X"
  }
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| AWS provider | Inherited from the calling project |

This module does not pin an `aws` provider version — the calling project's `terraform.tf` controls provider configuration and versioning.

## Notes

- The source directory is resolved with `abspath()` against `path.root`, which means it is evaluated relative to the root module being applied (the application's `.infra/` folder), not the location of this module.
- Each file is registered as its own `aws_s3_object` resource. Adding or removing a file produces a corresponding plan diff, so deployments are reviewable in `terraform plan` output.
- No real consumer of this module exists in `epic-web/.infra/`, `epic-api/.infra/`, or under `projects/` at the time of writing — the example above is synthetic.
