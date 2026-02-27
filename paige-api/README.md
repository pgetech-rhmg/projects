# PAIGE  
**PG&E AI for Innovation, Governance, and Enablement**

---

## Project Summary

PAIGE is an internal, enterprise-grade AI platform designed for PG&E to provide governed, secure, and practical AI-assisted capabilities across engineering, cloud, security, operations, and enterprise workflows.

The platform combines a **C#/.NET backend API** with an **Angular web frontend** to deliver:

- AI-assisted analysis, guidance, and automation  
- Strong governance and safety guardrails  
- Clear separation between AI execution, orchestration, and presentation  
- Streaming, interactive user experiences  

PAIGE is intentionally designed as a **platform**, not a single chatbot, enabling expansion into repo analysis, RAG, DevSecOps governance, and internal advisory tools.

---

## High-Level Architecture

```
┌──────────────┐
│  Angular UX  │  (Paige.Web)
│──────────────│
│  - Chat UI   │
│  - Streaming │
│  - Analysis  │
└──────┬───────┘
       │ HTTPS / SSE
┌──────▼───────┐
│  .NET API    │  (Paige.Api)
│──────────────│
│  - Routing   │
│  - Context   │
│  - Packs     │
│  - AI Exec   │
│  - Streaming │
└──────┬───────┘
       │
┌──────▼──────────────┐
│ AI Providers        │
│ (PortKey / LLMs)    │
└─────────────────────┘
```

---

## Application Structure

```
Paige.Api (https://github.com/pgetech/paige-api)       # Backend API (.NET)
Paige.Web (https://github.com/pgetech/paige-web)       # Frontend UX (Angular)
```

---

## Backend: Paige.Api

### Purpose

`Paige.Api` is the **orchestration and governance layer** for PAIGE. It is responsible for:

- Accepting user requests from the UX  
- Applying routing, classification, and safety logic  
- Injecting appropriate context packs  
- Executing AI requests via PortKey (or alternate providers)  
- Streaming responses back to the client  

### Key Responsibilities

- AI execution and streaming (SSE)  
- Context pack resolution and injection  
- Governance and safety enforcement  
- Request classification and routing  
- Provider abstraction (no hard dependency on a single LLM vendor)  

### Internal Structure (Simplified)

```
Paige.Api/
├── Controllers/            # HTTP + streaming endpoints
├── Engine/                 # Core orchestration logic
│   ├── CfnConvertor/
│   |   ├── Cfn/
│   |   ├── Scan/
│   |   └── Terraform/
│   ├── Chat/
│   ├── Common/
│   ├── Job/
│   ├── PortKey/            # AI execution, PortKey integration
│   └── RepoAssessment/
│   |   ├── AI/
│   |   ├── Dependencies/
│   |   ├── Detection/
│   |   ├── Linking/
│   |   ├── Model/
│   |   └── Modernization/
├── Packs/                  # Context packs (governance, COE, etc.)
├── Program.cs
└── appsettings.json
```

### Design Characteristics

- Clean separation of concerns  
- Provider-agnostic AI execution  
- Streaming-first response model  
- Strong emphasis on deterministic behavior and auditability  

---

## Frontend: Paige.Web

### Purpose

`Paige.Web` provides the **interactive user experience** for PAIGE. It focuses on clarity, responsiveness, and real-time interaction with AI responses.

### Key Responsibilities

- Chat-style UI with streaming updates  
- Rendering markdown, tables, and structured content  
- Managing conversation state and history  
- Providing a clean enterprise-ready UX  
- Providing repo analysis 
- Create Terraform project based on CloudFormation code  

### Internal Structure (Simplified)

```
Paige.Web/
├── src/
│   ├── app/
│   │   ├── classes/
│   │   ├── components/
│   │   ├── core/           # Core logic for UX interface (includes MSAL security)
│   │   ├── models/
│   │   ├── pages/
│   │   └── services/
│   ├── assets/
│   ├── environments/
│   ├── fonts/
│   └── styles/
├── angular.json
└── package.json
```

### Design Characteristics

- Angular + TypeScript  
- Streaming-aware UI updates  
- Strong separation between UI and API concerns  
- SCSS-based theming and layout control  

---

## Design Principles

PAIGE is built around the following core principles:

- **Governance First** – AI responses are routed, constrained, and contextualized  
- **Safety by Design** – No direct, unmediated model access  
- **Extensibility** – New packs, providers, and workflows can be added easily  
- **Transparency** – Clear reasoning, traceability, and explainability  
- **Enterprise Readiness** – Security, scale, and compliance are non-negotiable  

---

## Context Packs

Context Packs are a core architectural concept in PAIGE. They enable:

- Controlled injection of trusted knowledge  
- Domain-specific guidance (e.g., Cloud COE, Security)  
- Risk-aware response shaping  

Each pack includes structured metadata (audience, domains, risk level, priority) and a curated prompt.

---

## Intended Use Cases

- PG&E internal AI advisory assistant  
- DevSecOps and Cloud governance guidance  
- Repository and architecture analysis  
- Policy-aligned technical recommendations  
- Future RAG over internal documentation  

---

## Future Direction

PAIGE is intentionally designed to evolve into:

- Repository scanning and code intelligence  
- RAG over internal wikis and SharePoint  
- Governance-enforced AI agents  
- Deeper DevSecOps automation and platform intelligence  

---

## Status

This repository represents an **active platform foundation** intended for continued iteration, expansion, and enterprise adoption within PG&E.

