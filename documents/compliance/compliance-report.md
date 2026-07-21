# EPIC Compliance Reviewer — Report

- **Tool:** epic-compliance vdev
- **Spec:** T&S R&C Unified Controls Framework-APP.md
- **Repo:** `projects/ai-code-reviewer/Application-Codebase`
- **Scanned:** 2026-07-08T18:22:08Z

## Summary

| Verdict | Count |
|---|---:|
| FAIL | 7 |
| PARTIAL | 7 |
| PASS | 2 |
| MANUAL | 59 |
| N/A | 1 |
| **Total** | **76** |

## Findings

### FAIL (7)

#### AC-03-00 — Access Enforcement

- **Requirement:** Enforce approved authorizations for logical access in accordance with access control policies; deny by default; enforce server-side.
- **Verdict:** FAIL — API route handlers (repos.ts, scans.ts) invoke services directly with no authorization checks; rbacEnabled is explicitly false/backlog, and the deny-by-default and @Authorize references are only prompt/context strings for the scanner, not real enforcement in this app. (LLM-reviewed)
- **Evidence:**
  - `src/api/routes/repos.ts:19`
  - `src/api/routes/repos.ts:20`
  - `src/api/routes/repos.ts:55`
  - `src/api/routes/repos.ts:57`
  - `src/api/routes/repos.ts:58`

#### AC-06-00 — Unsuccessful Logon Attempts (account lockout) · **HARD**

- **Requirement:** Enforce a limit of no more than 10 consecutive invalid logon attempts by a user during any 60-minute period; automatically lock the account/node for at least 15 minutes when the maximum is exceeded.
- **Verdict:** FAIL — Authentication present but no account-lockout mechanism (10 attempts / 60 min, lock >=15 min) detected.
- **Remediation:** Enforce >=10 invalid attempts per 60 min then lock >=15 min on the authentication path.

#### AC-07-00 — System Use Notification (banner) · **HARD**

- **Requirement:** Display a system-use notification banner before granting access, stating: users are accessing a PG&E system; usage may be monitored/recorded/audited; unauthorized use is prohibited; use indicates consent to monitoring.
- **Verdict:** FAIL — Logon interface present but no system-use notification banner detected.
- **Remediation:** Display a use-notification banner with the four mandated statements before granting access.

#### AC-08-00 — Concurrent Session Control · **HARD**

- **Requirement:** Limit the number of concurrent sessions for all individual and shared accounts to two.
- **Verdict:** FAIL — Sessions present but no concurrent-session cap (limit of 2) detected.
- **Remediation:** Limit concurrent sessions per account to 2.

#### AC-12-00 — Event types selected for logging · **HARD**

- **Requirement:** Identify and log the security-relevant event types the system is capable of logging: authentication events, authorization grants/denials, privilege escalation, configuration changes, intrusion/anomaly events, and related categories.
- **Verdict:** FAIL — The evidence consists only of a guidance comment instructing developers to 'log security events' and a description of Lightning Web Security; there is no actual implementation code logging authentication, authorization, privilege escalation, or configuration change events. (LLM-reviewed)
- **Evidence:**
  - `src/platform/language-context.ts:175`
  - `src/platform/platform-context.ts:89`

#### AU-02-00 — Event Logging (audit record content) · **HARD**

- **Requirement:** Ensure audit records establish: (a) what type of event occurred, (b) when, (c) where, (d) source of the event, (e) outcome, and (f) identity of any individual associated with the event.
- **Verdict:** FAIL — The evidence shows only a simple progress/operational logging function accepting a pass label and message string; it contains no structured audit fields for event type, timestamp, location, source, outcome, or user identity. (LLM-reviewed)
- **Evidence:**
  - `src/cli.ts:127`
  - `src/cli.ts:138`

#### IA-02-00 — Identification and Authentication (organizational users)

- **Requirement:** Uniquely identify and authenticate organizational users and associate that identity with processes acting on behalf of those users.
- **Verdict:** FAIL — Evidence consists of outbound GitHub token injection for git operations and documentation/prompt text describing authentication best practices for other frameworks; there is no enforced request authentication (middleware/guards) on any inbound endpoints. (LLM-reviewed)
- **Evidence:**
  - `src/github/git-operations.ts:13`
  - `src/github/git-operations.ts:16`
  - `src/github/git-operations.ts:74`
  - `src/platform/dotnet-context.ts:15`
  - `src/platform/dotnet-context.ts:32`

### PARTIAL (7)

#### AU-06-00 — Time Stamps · **HARD**

- **Requirement:** Use internal system clocks to generate UTC-based time stamps for audit records; synchronize to enterprise reference clocks where available.
- **Verdict:** PARTIAL — UTC timestamp generation found; confirm all audit records (not just some) carry UTC time stamps.
- **Evidence:**
  - `src/api/server.ts:61`
  - `src/cli.ts:283`
  - `src/db/database.ts:229`
  - `src/db/repositories/code-review.repository.ts:15`
  - `src/db/repositories/file-state.repository.ts:15`

#### AU-08-00 — Time Stamps (non-repudiation)

- **Requirement:** Record time stamps sufficient to attribute logged actions to individuals (non-repudiation).
- **Verdict:** PARTIAL — Timestamps present; non-repudiation attribution requires user identity in logs.
- **Evidence:**
  - `src/api/server.ts:61`
  - `src/cli.ts:283`
  - `src/db/database.ts:229`
  - `src/db/repositories/code-review.repository.ts:15`
  - `src/db/repositories/file-state.repository.ts:15`

#### AU-10-00 — Non-repudiation / audit retention

- **Requirement:** Retain audit records consistent with the records-retention policy.
- **Verdict:** PARTIAL — Retention config found.
- **Evidence:**
  - `package-lock.json:923`

#### AU-11-00 — Audit Record Retention/Generation

- **Requirement:** Generate and retain audit records for the defined event types.
- **Verdict:** PARTIAL — Logging present; audit-record generation for defined events must be confirmed.
- **Evidence:**
  - `src/api/server.ts:21`
  - `src/cli.ts:127`
  - `src/cli.ts:138`
  - `src/github/git-operations.ts:37`

#### CM-06-00 — Configuration Settings / least functionality

- **Requirement:** Configure the system for least functionality; disable/restrict unneeded ports, protocols, and services.
- **Verdict:** PARTIAL — Network exposure found; confirm least-functionality (no needless ports/services).
- **Evidence:**
  - `src/ai/passes/comprehension.ts:31`
  - `src/ai/passes/comprehension.ts:58`
  - `src/ai/passes/comprehension.ts:100`
  - `src/ai/passes/detection.ts:96`
  - `src/ai/passes/detection.ts:108`

#### CP-10-00 — System Recovery / unique user authentication

- **Requirement:** Authenticate users uniquely; no shared/anonymous access to protected functions.
- **Verdict:** PARTIAL — User identity concepts present; confirm unique authentication.
- **Evidence:**
  - `src/github/git-operations.ts:13`
  - `src/github/git-operations.ts:16`
  - `src/github/git-operations.ts:74`
  - `src/platform/dotnet-context.ts:25`
  - `src/platform/dotnet-context.ts:32`

#### SC-08-00 — Transmission Confidentiality and Integrity

- **Requirement:** Protect the confidentiality and integrity of transmitted information (TLS in transit).
- **Verdict:** PARTIAL — TLS/HTTPS references found; edge termination (ALB/ingress) may satisfy this in IaC.
- **Evidence:**
  - `src/ai/batch-processor.ts:43`
  - `src/ai/batch-processor.ts:54`
  - `src/ai/passes/comprehension.ts:157`
  - `src/ai/passes/detection.ts:542`
  - `src/ai/passes/flow-tracing.ts:160`

### PASS (2)

#### CM-05-00 — Access Restrictions for Change / secure baseline

- **Requirement:** Apply and enforce a secure baseline configuration (STIG/CIS) and restrict changes to it.
- **Verdict:** PASS — Baseline/hardening references found.
- **Evidence:**
  - `src/ai/passes/remediation.ts:36`
  - `src/ai/passes/remediation.ts:64`
  - `tests/ai/passes/remediation-enhanced.property.test.ts:75`
  - `tests/ai/passes/remediation-enhanced.property.test.ts:95`
  - `tests/ai/passes/remediation-enhanced.property.test.ts:99`

#### SI-07-00 — Software, Firmware, and Information Integrity

- **Requirement:** Employ integrity verification for software/artifacts (e.g. signature/HMAC/checksum verification).
- **Verdict:** PASS — The code implements genuine HMAC-SHA256 signature verification for GitHub webhooks using createHmac and timingSafeEqual for constant-time comparison, wired into the webhook service to reject invalid signatures, and covered by unit tests validating tampered payloads and wrong secrets. (LLM-reviewed)
- **Evidence:**
  - `src/api/routes/webhooks.ts:6`
  - `src/api/routes/webhooks.ts:7`
  - `src/api/routes/webhooks.ts:12`
  - `src/api/routes/webhooks.ts:14`
  - `src/api/routes/webhooks.ts:24`

### MANUAL (59)

#### AC-02-03 — Account Management — disable inactive accounts

- **Requirement:** Disable accounts that are in violation of policy or inactive for 60 business days.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-02-05 — Account Management — inactivity logout

- **Requirement:** Require users to log out when leaving a system unattended (process/runtime enforcement).
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-02-11 — Account Management — usage conditions

- **Requirement:** Enforce organization-defined circumstances/usage conditions for accounts.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-02-12 — Account Management — monitoring for atypical usage

- **Requirement:** Monitor and report atypical usage of system accounts to Cybersecurity.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-02-13 — Account Management — disable high-risk accounts

- **Requirement:** Disable accounts of individuals posing significant risk within a defined time period.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-05-00 — Separation of Duties

- **Requirement:** Define and enforce separation of duties across roles and system access authorizations.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AC-10-00 — Concurrent Session Control (policy)

- **Requirement:** Limit concurrent sessions per organization policy.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AU-03-00 — Content of Audit Records

- **Requirement:** Ensure audit records contain the individuals/subjects/objects associated with each event.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AU-03-03 — Content of Audit Records — additional elements

- **Requirement:** Include organization-defined additional elements in audit records per the privacy risk assessment.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AU-05-00 — Response to Audit Logging Process Failures

- **Requirement:** Alert on and respond to audit logging process failures.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### AU-12-00 — Audit Record Generation (coverage)

- **Requirement:** Provide audit record generation capability for the defined auditable events across the system.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CA-03-00 — Information Exchange

- **Requirement:** Approve and manage system interconnection/information-exchange agreements; review every 3 years or on posture change.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CA-08-00 — Penetration Testing

- **Requirement:** Conduct penetration testing on organization-defined (e.g. external-facing) systems.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CA-09-00 — Internal System Connections

- **Requirement:** Authorize internal system connections and document interface characteristics.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-02-00 — Baseline Configuration

- **Requirement:** Develop, document, and maintain a current baseline configuration; update on upgrades/patches/significant changes.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-03-00 — Configuration Change Control

- **Requirement:** Operate a Configuration Change Control Board (CAB) convening at least monthly.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-04-00 — Impact Analysis

- **Requirement:** Analyze changes to the system for security/privacy impact before implementation.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-07-00 — Least Functionality (policy)

- **Requirement:** Prohibit/restrict organization-defined functions, ports, protocols, and software.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-08-00 — System Component Inventory

- **Requirement:** Maintain an inventory of system components and update on component change.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-08-09 — Assignment of Components to Systems

- **Requirement:** Assign system components to a system and document the application owner of the assignment.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CM-09-00 — Configuration Management Plan

- **Requirement:** Develop and protect a configuration management plan from unauthorized disclosure/modification.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CP-02-00 — Contingency Plan

- **Requirement:** Develop and maintain a contingency plan including testing and training.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### CP-04-00 — Contingency Plan Testing

- **Requirement:** Test the contingency plan and take corrective actions as needed.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### IA-08-00 — Identification and Authentication (non-organizational users)

- **Requirement:** Uniquely identify and authenticate non-organizational users (or processes acting on their behalf).
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### IA-11-00 — Re-Authentication

- **Requirement:** Require re-authentication after a password reset or when required by applicable regulations.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### IA-12-00 — Identity Proofing

- **Requirement:** Identity-proof individuals before issuing credentials.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### MP-02-00 — Media Access

- **Requirement:** Restrict access to organization-defined types of digital and non-digital media.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### PL-02-00 — System Security and Privacy Plans

- **Requirement:** Develop, document, and maintain system security and privacy plans.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### PS-04-00 — Personnel Termination

- **Requirement:** Disable access and recover assets upon personnel termination.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### PS-05-00 — Personnel Transfer

- **Requirement:** Review and adjust access within 1 business day of reassignment or transfer.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### RA-03-00 — Risk Assessment

- **Requirement:** Conduct and maintain risk assessments of the system and its environment.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### RA-05-00 — Vulnerability Monitoring and Scanning

- **Requirement:** Monitor and scan for vulnerabilities with the capability to update the vulnerabilities scanned.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### RA-08-00 — Privacy Impact Assessments

- **Requirement:** Conduct privacy impact assessments where applicable.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-00 — Developer Configuration Management

- **Requirement:** Require developers to perform configuration management during development/maintenance.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-01 — Developer CM — software/firmware integrity verification

- **Requirement:** Require developers to verify integrity of software and firmware components.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-02 — Developer CM — alternative configuration management

- **Requirement:** Provide an independent/dedicated developer configuration management capability.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-04 — Developer CM — trusted generation

- **Requirement:** Compare generated versions of security-relevant hardware/source/object code with previous versions.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-05 — Developer CM — mapping integrity for version control

- **Requirement:** Maintain an on-site master copy of data for the current version under version control.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-10-06 — Developer CM — trusted distribution

- **Requirement:** Execute procedures for ensuring trusted distribution from master copies.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-11-00 — Developer Testing and Evaluation

- **Requirement:** Require developers to test/evaluate and remediate flaws identified during testing.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-17-00 — Developer Security and Privacy Architecture and Design

- **Requirement:** Require a developer security/privacy architecture with a unified protection approach.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SA-21-00 — Developer Screening

- **Requirement:** Screen developers against organization-defined screening criteria.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SC-04-00 — Information in Shared System Resources

- **Requirement:** Prevent unauthorized information transfer via shared system resources.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SC-10-00 — Network Disconnect

- **Requirement:** Terminate the network connection after 20 minutes of inactivity.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SC-28-00 — Protection of Information at Rest

- **Requirement:** Protect the confidentiality and integrity of information at rest (encryption at rest).
- **Verdict:** MANUAL — No IaC in repo to evaluate; at-rest encryption is a storage/infra property — requires attestation.

#### SI-02-00 — Flaw Remediation

- **Requirement:** Identify, report, and remediate system flaws via the configuration management process.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-03-00 — Malicious Code Protection

- **Requirement:** Employ malicious-code detection/eradication mechanisms.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-04-00 — System Monitoring

- **Requirement:** Monitor the system to detect attacks and indicators of potential attacks.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-05-00 — Security Alerts, Advisories, and Directives

- **Requirement:** Receive, generate, and disseminate security alerts/advisories/directives.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-07-15 — Code Authentication

- **Requirement:** Authenticate organization-defined software/firmware components prior to installation.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SI-12-00 — Information Management and Retention

- **Requirement:** Manage and retain information per applicable laws, regulations, and policies.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-12-01 — Information Management — limit PII elements

- **Requirement:** Limit personally identifiable information elements retained/processed.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SI-12-02 — Information Management — minimize PII for research/testing

- **Requirement:** Minimize use of PII for research, testing, or training via defined techniques.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SI-12-03 — Information Disposal

- **Requirement:** Dispose of information using organization-defined techniques.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SI-16-00 — Memory Protection

- **Requirement:** Implement organization-defined controls to protect memory from unauthorized code execution.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SI-19-00 — De-identification

- **Requirement:** De-identify data as required.
- **Verdict:** MANUAL — The framework provides no machine-evaluable criterion for this control; manual review required.

#### SR-05-02 — Acquisition Strategies — modification/update

- **Requirement:** Apply controls when acquiring, modifying, or updating supply-chain elements.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SR-06-00 — Supplier Assessments and Reviews

- **Requirement:** Assess and review suppliers per organization-defined procedures.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

#### SR-09-01 — Tamper Resistance and Detection — life cycle

- **Requirement:** Apply anti-tamper controls across the system development life cycle.
- **Verdict:** MANUAL — Requires human/runtime attestation — this control (personnel, process, or operational evidence) cannot be verified from source code.

### N/A (1)

#### AC-02-04 — Account Management (audit actions)

- **Requirement:** Automatically audit account creation, modification, enabling, disabling, and removal actions.
- **Verdict:** N/A — No account-management operations found.

