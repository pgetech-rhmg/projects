# epic-pipeline-module-aws-sns

## Overview

Reusable Terraform module that provisions an AWS SNS topic and optional email subscriptions. Used by EPIC application repositories under `.infra/` to expose alert, event, and feedback channels that downstream resources (Lambdas, CloudWatch alarms, SES configuration sets) can publish to or be invoked from.

The module is intentionally minimal: one topic, optional fan-out to a list of email endpoints, and consistent tagging. Composition (Lambda subscriptions, SES bindings, IAM policies) is handled in the consuming `.infra/` configuration.

## Resources

| Resource | Purpose |
|----------|---------|
| `aws_sns_topic.this` | The SNS topic |
| `aws_sns_topic_subscription.email` | One email subscription per address in `email_subscriptions` |

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `topic_name` | `string` | SNS topic name. |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | `string` | `""` | Display name used for SMS and email subscriptions. |
| `email_subscriptions` | `list(string)` | `[]` | Email addresses to subscribe to the topic. Each address must be confirmed by the recipient before AWS will deliver messages. |
| `tags` | `map(string)` | `{}` | Resource tags applied to the topic. |

## Outputs

| Name | Description |
|------|-------------|
| `topic_arn` | ARN of the SNS topic. |
| `topic_name` | Name of the SNS topic. |

## Usage in a Terraform project

Typical use from an application's `.infra/` directory. The application's `.pipeline/epic.json` controls when EPIC runs `terraform apply` against this configuration.

```hcl
module "sns_observability_alerts" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sns.git?ref=main"

  topic_name          = "cma-observability-alerts-${var.environment}"
  display_name        = "CMA Observability Alerts"
  email_subscriptions = var.alert_emails
  tags                = module.tags.tags
}

module "sns_ses_feedback" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sns.git?ref=main"

  topic_name   = "cma-ses-feedback-${var.environment}"
  display_name = "CMA SES Bounce/Complaint Feedback"
  tags         = module.tags.tags
}
```

## Usage from another module

Compose the topic with consumers — for example, granting an SNS-invoked Lambda permission to be triggered by the topic, or wiring the topic ARN into a CloudWatch alarm action.

```hcl
module "sns_ses_bounce" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-aws-sns.git?ref=main"

  topic_name   = "${var.project_tag}-ses-bounce-${var.environment}"
  display_name = "${var.project_tag} SES bounce/complaint events"
  tags         = module.tags.tags
}

resource "aws_lambda_permission" "ses_bounce_sns" {
  statement_id  = "AllowSnsInvokeBounceHandler"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda["nfr-ses-bounce-handler"].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_ses_bounce.topic_arn
}
```

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/aws` | `~> 5.90` |

## Notes

- Email subscriptions are created in `PendingConfirmation` state. AWS sends a confirmation email to each address; SNS will not deliver messages to an address until the recipient clicks the confirmation link. Subsequent `terraform apply` runs do not re-trigger confirmation for already-confirmed addresses.
- This module does not create a topic policy. If publishers in other accounts or services (e.g., SES, CloudWatch, S3) need to publish to the topic, attach an `aws_sns_topic_policy` in the consuming configuration.
