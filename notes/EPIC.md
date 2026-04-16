# EPIC: One Pipeline, Every App

## The Netflix Analogy

Think of EPIC like a Netflix account.

You have **one Netflix account**. It works on every TV in your house. Each TV can play a different movie at the same time. You don't need a separate Netflix subscription for the living room, the bedroom, the kitchen, and the garage.

| Netflix | EPIC |
|---|---|
| Your Netflix account | The EPIC pipeline |
| Each TV / room | Each application team |
| The movie playing | An active deployment run |
| Your remote + profile | The app's `epic.json` config |

Nobody at home builds their own streaming service. They just press play.

## How It Works

Every app team gets the same pipeline. They don't build one, maintain one, or debug one. They provide a small config file (`.pipeline/epic.json`) that tells EPIC what to deploy and where. That's it.

EPIC handles the rest: authentication, infrastructure provisioning, testing gates, artifact management, and deployment to AWS.

## Why This Matters

**Without EPIC:** 30 app teams build 30 pipelines. Each one is slightly different. Each one breaks differently. Each one needs its own expertise to fix. Security reviews multiply. Compliance audits become a nightmare. Onboarding takes weeks.

**With EPIC:** 30 app teams use one pipeline. It's consistent, auditable, and maintained by a single team. Onboarding takes hours. Security and compliance are baked in once, not bolted on 30 times.

## The Bottom Line

We don't need every team to become a CI/CD expert. We need every team to ship their code safely and reliably. EPIC is how we do that.