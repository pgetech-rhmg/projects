# ADO Pipeline + IDP Strategy vs. Harness

**Date:** March 2025

---

## The Argument in One Paragraph

Harness is a great platform. For PG&E, it is overkill at a significant cost. PG&E already licenses ADO, GitHub, SonarQube, and JFrog, and the centralized ADO Pipeline is already built. Those four tools cover every capability Harness offers for our use case, at no additional cost, with no new vendor dependency, and with all pipeline logic staying under PG&E control. The right answer is to build on what we have.

---

## What Harness Actually Is

Harness bundles CI/CD, an Internal Developer Portal (built on open-source Backstage), security scanning, and progressive delivery into one SaaS product. Enterprise pricing is not public; however, buyer data from Vendr.com puts the range at $50,000 to $234,000 per year. That range reflects a base set of modules at a negotiated headcount. For PG&E's full scope, CI, CD, IDP, and security scanning each require a separate per-developer license, meaning the real number grows significantly from whatever lands in the initial sales conversation.

Two things worth understanding before the comparison:

- The Harness IDP cannot be purchased without Harness CI/CD. They are inseparable.
- App teams using Harness still define their own pipelines, services, and environments inside Harness. It does not eliminate pipeline ownership. It moves it into Harness.

---

## Feature Comparison

| Capability | Harness | ADO + GitHub + SonarQube + JFrog |
|---|---|---|
| CI/CD Pipelines | Each team defines their own pipeline in Harness | Cloud COE owns one centralized pipeline; app teams submit a config file |
| App Team Onboarding | Learn Harness, define services, environments, and stages | Submit a config file. No pipeline knowledge required. |
| Code Quality Gates | External tool required via plugin | SonarQube native CI gate; pipeline fails on violations |
| Artifact Management | Harness registry or JFrog as an integration | JFrog Artifactory; OIDC-integrated with ADO |
| Approval Gates | Built-in pipeline approval steps | Native ADO environment approvals with Entra ID groups |
| RBAC / Identity | Harness-native RBAC (reported as complex) | Entra ID + ADO group mapping; SSO already in place |
| IDP Service Catalog | Backstage-based; requires Harness CD license | Lightweight portal on ADO REST APIs; PG&E-owned |
| Deployment Observability | Built-in Harness dashboards | ADO REST API surfaces run history, logs, and status |
| Audit Trail | Built-in | ADO audit log + GitHub commit and PR history |
| Data Boundary | Flows through Harness SaaS | Stays within PG&E network and Microsoft compliance boundary |
| Vendor Lock-in | High. All config lives in Harness. | None. YAML lives in GitHub under PG&E control. |
| Annual License Cost | $50,000 to $234,000/yr | Included in existing Microsoft Enterprise Agreement |

---

## Cost and Resource Comparison

| Area | Harness | ADO + Existing Tools |
|---|---|---|
| Platform License | $50K to $234K/yr | No incremental cost |
| Procurement | RFP, legal review, contract execution | No action needed; tools already under contract |
| Security Review | New SaaS vendor; full review required | Existing approved vendors |
| Infrastructure | Harness Delegate on EC2/containers; PG&E manages it | ADO self-hosted agents already deployed |
| App Team Effort | Each team configures Harness ongoing | Each team submits a config file |
| Platform Expertise | 1-2 engineers deep in Harness, delegates, Backstage plugins | 1-2 Cloud COE engineers using existing ADO knowledge |
| IDP Portal | Bundled with Harness CI/CD; no separation | Thin UI layer on Microsoft-supported ADO REST APIs; PG&E owns it outright |
| Setup and Training | New platform for every team. Engineers learn Harness internals, delegates, and IDP schema. App teams learn enough Harness to define their own services. Months of ramp time before full adoption. | ADO Pipeline is already built. App teams submit a config file. No ramp time required. |
| Exit Cost | High. Everything lives in Harness. | None. YAML is in GitHub. Portal is a standalone app. |

---

## The IDP PG&E Builds

Three layers deliver a full IDP on the composable platform:

**Pipeline Engine (ADO):** The centralized ADO Pipeline is already built and operational. App teams provide a config file. The pipeline handles build, test, artifact publication, and deployment. This is not a proposal, it exists today.

**Quality and Artifact Gates (SonarQube + JFrog):** Every build runs SonarQube. Every artifact lands in JFrog. Both are already integrated with ADO.

**Developer Portal UI:** A lightweight app on top of Microsoft-supported ADO REST APIs, delivering a service catalog, self-service deployment form, and run history dashboard. This is a thin UI layer, not a custom platform. PG&E owns it permanently with no ongoing license dependency. If a richer catalog experience is needed, open-source Backstage can serve as the portal framework without requiring a Harness license.

---

## On Support and Reliability

A common concern with a composable platform is supportability. The ADO Pipeline is built on Azure DevOps, a Microsoft enterprise product with full SLA and 24/7 support. SonarQube and JFrog are both established enterprise tools with dedicated support contracts. The developer portal is a thin UI on a Microsoft-supported API, not a fragile custom system. The Cloud COE team owns and maintains the pipeline templates, the same way a platform team would own any shared infrastructure.

Harness support exists, but it does not eliminate operational responsibility. PG&E would still own the delegate infrastructure, the pipeline definitions, and the IDP configuration. The difference is that with Harness, a vendor sits between PG&E and its own deployment platform.

---

## Recommendation

The ADO Pipeline is already built. The tools are already licensed. The path forward is to complete the platform, not replace it.

- Publish the app team config file schema and onboarding process
- Enforce SonarQube and JFrog as mandatory pipeline stages across all teams
- Scope and build the developer portal as a thin UI on ADO REST APIs
- Use open-source Backstage as the portal framework if a richer service catalog is needed

This delivers everything Harness promises, on infrastructure PG&E already owns, without a six-figure vendor contract or months of ramp time for every team to learn a new platform.
