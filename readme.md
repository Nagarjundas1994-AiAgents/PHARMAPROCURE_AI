<div align="center">

# 💊 PharmaProcure AI

### Intelligent Pharmaceutical Procurement & Supply Chain System on SAP BTP

[![SAP BTP](https://img.shields.io/badge/SAP-BTP-blue?style=flat-square&logo=sap)](https://www.sap.com/products/technology-platform.html)
[![CAP Node.js](https://img.shields.io/badge/CAP-Node.js-339933?style=flat-square&logo=node.js)](https://cap.cloud.sap/)
[![Fiori Elements](https://img.shields.io/badge/Fiori-Elements-0070F2?style=flat-square&logo=sap)](https://experience.sap.com/fiori-design/)
[![LangGraph.js](https://img.shields.io/badge/LangGraph.js-AI_Agents-8B5CF6?style=flat-square)](https://langchain-ai.github.io/langgraph/)
[![HANA Cloud](https://img.shields.io/badge/HANA-Cloud-orange?style=flat-square)](https://www.sap/products/hana.html)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Think: SAP Ariba + AI Brain on Top**

A comprehensive enterprise application that manages Purchase Orders, Vendors, Drug Inventory, Budgets, and Compliance — powered by 4 specialist AI agents that review every PO before approval using LangGraph.js multi-agent orchestration.

[🚀 Quick Start](#-quick-start) · [📖 Documentation](#-documentation) · [🏗️ Architecture](#️-architecture) · [📅 Implementation Plan](#-implementation-plan)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#️-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
  - [Data Model](#data-model)
  - [Services](#services)
  - [AI Agents](#ai-agents)
  - [Fiori UI](#fiori-ui)
  - [Security](#security)
- [Implementation Plan](#-implementation-plan)
- [BTP Services Used](#-btp-services-used)
- [Feature Coverage Map](#-feature-coverage-map)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

PharmaProcure AI is an end-to-end pharmaceutical procurement platform built on **SAP Business Technology Platform (BTP)**. It combines the power of **SAP Cloud Application Programming Model (CAP)** for backend services with **LangGraph.js** multi-agent AI orchestration to automate Purchase Order reviews.

### What It Does

| Capability | Description |
|:---|:---|
| 🛒 **Purchase Order Management** | Full CRUD with draft support, multi-level approvals, and audit trails |
| 🤖 **AI Agent Review** | 4 specialist agents review budget, risk, compliance, and financials before approval |
| 📊 **Analytics & Reporting** | Spend analysis, vendor performance, and budget utilization dashboards |
| 🔒 **Compliance & Security** | Narcotics tracking, license verification, cold chain confirmation, role-based access |
| 📨 **Event-Driven Architecture** | Real-time messaging via SAP Event Mesh for downstream system integration |

---

## ✨ Key Features

<table>
<tr>
<td width="50%">

### 🤖 AI-Powered Procurement
- **4 Specialist AI Agents** running in parallel
- **Orchestrator Agent** coordinates all reviews
- **Human-in-the-Loop** escalation for edge cases
- **Audit Trail** for every AI decision
- **Confidence Scoring** on all recommendations

</td>
<td width="50%">

### 📋 Enterprise PO Management
- **Draft-Enabled Forms** — save & resume anytime
- **Bound Actions** — Approve, Reject, AI Review, Send Back
- **Bulk Operations** — approve multiple POs at once
- **Soft Delete** — recoverable record deletion
- **Computed Fields** — auto-calculated totals & taxes

</td>
</tr>
<tr>
<td width="50%">

### 📊 Analytics & Insights
- **Spend by Department** — aggregated reporting
- **PO Status Distribution** — visual breakdowns
- **Vendor Spend Analysis** — risk-informed decisions
- **Budget Utilization** — real-time tracking

</td>
<td width="50%">

### 🔒 Security & Compliance
- **Role-Based Access Control** — Viewer / Procurer / Manager / Admin
- **XSUAA Integration** — enterprise-grade auth
- **Narcotics Tracking** — controlled substance handling
- **License Verification** — vendor compliance checks
- **Cold Chain Confirmation** — temperature-sensitive logistics

</td>
</tr>
</table>

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PHARMAPROCURE AI — ARCHITECTURE                  │
│                                                                      │
│  ┌─────────────┐    OData V4    ┌─────────────────────────────┐     │
│  │  Fiori UI   │ ◄────────────► │  CAP Backend (Node.js)      │     │
│  │  List Report│                │                             │     │
│  │  Object Page│                │  ProcurementService         │     │
│  │  FPM Macros │                │  AdminService               │     │
│  │  Charts     │                │  AnalyticsService           │     │
│  └─────────────┘                │                             │     │
│                                 │  Service Handlers           │     │
│  ┌─────────────┐                │  ├── BEFORE (validate)      │     │
│  │  External   │ ◄────────────► │  ├── ON (logic + next())    │     │
│  │  Vendor API │  Remote Svc    │  └── AFTER (enrich)         │     │
│  └─────────────┘                │                             │     │
│                                 │  ┌──────────────────────┐   │     │
│  ┌─────────────┐  SAP Messaging │  │  LangGraph AI Agents │   │     │
│  │  SAP Event  │ ◄────────────► │  │  ┌────────────────┐  │   │     │
│  │  Mesh       │                │  │  │  Orchestrator  │  │   │     │
│  └─────────────┘                │  │  ├────────────────┤  │   │     │
│                                 │  │  │ PO Review Agent│  │   │     │
│  ┌─────────────┐                │  │  │ Vendor Risk    │  │   │     │
│  │  XSUAA /    │ ◄────────────► │  │  │ Budget Agent   │  │   │     │
│  │  IAS Auth   │                │  │  │ Compliance     │  │   │     │
│  └─────────────┘                │  │  └────────────────┘  │   │     │
│                                 │  └──────────────────────┘   │     │
│                                 │                             │     │
│                                 │  HANA Cloud DB              │     │
│                                 └─────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
```

### AI Agent Orchestration Flow

```
                    START
                      │
          ┌───────┬───┴───┬───────┐
          ▼       ▼       ▼       ▼
      poReview  vendor  budget  compliance    ← All run in PARALLEL
         │      Risk    Check    Check
          │       │       │       │
          └───────┴───┬───┴───────┘
                      ▼
               finalDecision
                      │
               ┌──────┴──────┐
               │             │
          No ▼         Yes ▼
           END      humanEscalation
                         │
                        END
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|:---|:---|:---|
| **Backend** | SAP CAP (Node.js) | OData V4 services, business logic, draft handling |
| **Database** | SAP HANA Cloud | Production database with HDI containers |
| **Frontend** | SAP Fiori Elements | Annotation-driven enterprise UI |
| **AI Engine** | LangGraph.js + Anthropic Claude | Multi-agent PO review orchestration |
| **Security** | XSUAA + IAS | Authentication & role-based authorization |
| **Messaging** | SAP Event Mesh | Asynchronous event-driven communication |
| **Deployment** | Cloud Foundry (MTA) | Multi-target application deployment |
| **Local Dev** | SQLite | Local development database via `cds watch` |

---

## 📁 Project Structure

```
pharmaprocure-ai/
│
├── db/
│   ├── schema.cds                 # All entities (master + transactional)
│   ├── data/                      # CSV seed data for local SQLite
│   └── hana/                      # HANA-specific synonyms & config
│
├── srv/
│   ├── procurement-service.cds    # Main OData service definition
│   ├── admin-service.cds          # Admin service definition
│   ├── analytics-service.cds      # Reporting / aggregation service
│   ├── procurement-service.js     # Main service handler (BEFORE/ON/AFTER)
│   ├── admin-service.js           # Admin handler
│   ├── procurement-service-annotations.cds  # SideEffects, OperationAvailable, ValueList
│   └── external/
│       └── vendor-api.cds         # Remote vendor verification service
│
├── agents/
│   ├── state.js                   # LangGraph shared state (Annotation)
│   ├── tools.js                   # LangGraph tools (CAP queries wrapped as tools)
│   ├── po-review-agent.js         # PO financial review agent
│   ├── vendor-risk-agent.js       # Vendor risk scoring agent
│   ├── budget-agent.js            # Budget validation agent
│   ├── compliance-agent.js        # Regulatory compliance agent
│   └── orchestrator.js            # Multi-agent StateGraph coordinator
│
├── app/
│   ├── po-list/                   # Fiori List Report
│   │   ├── webapp/
│   │   │   └── manifest.json      # Routing configuration
│   │   └── annotations.cds       # @UI.LineItem, @UI.SelectionFields
│   │
│   ├── po-detail/                 # Fiori Object Page
│   │   ├── webapp/
│   │   │   ├── manifest.json
│   │   │   └── ext/
│   │   │       ├── AISection.fragment.xml    # Custom AI section UI
│   │   │       └── AISection.js              # Custom section controller
│   │   └── annotations.cds       # @UI.HeaderInfo, @UI.Facets, @UI.FieldGroup
│   │
│   └── po-dashboard/              # Analytical Overview Page
│       ├── webapp/
│       └── annotations.cds
│
├── xs-security.json               # XSUAA security configuration
├── mta.yaml                       # MTA deployment descriptor
├── package.json                   # Node.js dependencies
└── .cdsrc.json                    # CDS runtime configuration
```

---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version | Purpose |
|:---|:---|:---|
| [Node.js](https://nodejs.org/) | ≥ 18 | CAP runtime |
| [@sap/cds-dk](https://cap.cloud.sap/docs/get-started/) | ≥ 8 | CAP CLI tools |
| [SAP BTP Account](https://www.sap.com/products/technology-platform/trial.html) | Trial | Cloud deployment |
| [LangGraph.js](https://langchain-ai.github.io/langgraph/) | Latest | AI agent orchestration |
| Anthropic API Key | — | LLM for AI agents |

### 1. Clone & Install

```bash
# Clone the repository
git clone https://github.com/your-org/pharmaprocure-ai.git
cd pharmaprocure-ai

# Install dependencies
npm install

# Install agent dependencies
cd agents && npm install && cd ..
```

### 2. Local Development

```bash
# Start CAP server with local SQLite
cds watch

# Open in browser: http://localhost:4004
# Fiori preview:   http://localhost:4004/po-list/webapp/index.html
```

### 3. Run AI Agents (Optional)

```bash
# Set your Anthropic API key
export ANTHROPIC_API_KEY=your-api-key-here

# The AI agents activate when you trigger "Run AI Review" in the UI
# or call the API directly:
curl -X POST "http://localhost:4004/procurement/POs('<po-id>')/ProcurementService.RunAIReview"
```

### 4. Deploy to SAP BTP

```bash
# Build MTA archive
npx mbt build

# Deploy to Cloud Foundry
cf deploy mta_archives/pharmaprocure-ai_1.0.0.mtar --delete-services --retries 3
```

---

## 📖 Documentation

### Data Model

The data model uses **CDS (Core Data Services)** with reusable aspects and well-defined entities:

#### Core Entities

| Entity | Description | Key Features |
|:---|:---|:---|
| `PurchaseOrders` | Main transactional entity | Draft-enabled, soft delete, AI fields |
| `POItems` | Line items (Composition) | Computed totals, tax calculations |
| `Vendors` | Master data | Risk scoring, blacklisting, license tracking |
| `Products` | Drug catalog | Narcotic flags, refrigeration requirements |
| `Budgets` | Department budgets | Computed available balance |
| `ComplianceChecks` | Regulatory verification | Narcotics, license, cold chain status |
| `AIRecommendationLog` | Audit trail | Full AI decision history |

#### Reusable Aspects

| Aspect | Purpose |
|:---|:---|
| `managed` | Auto-tracks `createdAt`, `createdBy`, `modifiedAt`, `modifiedBy` |
| `cuid` | Auto-generated UUID primary key |
| `softDelete` | Logical deletion with `isDeleted` flag |
| `addressable` | Common address fields |

#### Custom Types & Enums

```
POStatus:    DRAFT → SUBMITTED → AI_REVIEW → APPROVED / REJECTED / CANCELLED
RiskLevel:   LOW | MEDIUM | HIGH | CRITICAL
AgentDecision: APPROVE | REJECT | MANUAL_REVIEW | NEED_INFO
```

### Services

Three OData V4 services with distinct access levels:

| Service | Path | Purpose | Access |
|:---|:---|:---|:---|
| `ProcurementService` | `/procurement` | Main service — POs, catalog, budgets | `authenticated-user` |
| `AdminService` | `/admin` | Full control — all entities, vendor blacklisting | `admin` role |
| `AnalyticsService` | `/analytics` | Read-only aggregations for dashboards | `authenticated-user` |

#### Bound Actions (Operate on a Single PO)

| Action | Description | Available When |
|:---|:---|:---|
| `ApprovePO` | Approve a submitted PO | `status = 'SUBMITTED'` |
| `RejectPO` | Reject with reason | `status = 'SUBMITTED' or 'AI_REVIEW'` |
| `RunAIReview` | Trigger 4-agent AI review | `status ≠ 'APPROVED'` |
| `SendBackForRevision` | Return to procurer | `status = 'SUBMITTED'` |

#### Unbound Actions & Functions

| Operation | Type | Description |
|:---|:---|:---|
| `BulkApprove` | Action | Approve multiple POs in one call |
| `GetBudgetSummary` | Function | Get department budget utilization |
| `GetVendorRiskScore` | Function | Get vendor risk assessment |

### AI Agents

The AI system uses **LangGraph.js** with a multi-agent architecture:

#### Agent Responsibilities

| Agent | Role | Tools Used |
|:---|:---|:---|
| **PO Review Agent** | Financial reasonableness check | `get_po_details`, `get_similar_approved_pos` |
| **Vendor Risk Agent** | Vendor reliability assessment | `get_vendor_history` |
| **Budget Agent** | Budget availability validation | `check_budget` |
| **Compliance Agent** | Regulatory compliance check | `check_compliance` |
| **Orchestrator** | Coordinates all agents, makes final decision | All of the above |

#### How It Works

1. User clicks **"Run AI Review"** on a PO
2. CAP handler sets status to `AI_REVIEW` and calls the orchestrator
3. Orchestrator launches **all 4 agents in parallel**
4. Each agent uses tools to query the CAP database and analyze data
5. Results are passed to a **final decision node** that weighs all assessments
6. If confidence is low or compliance issues exist → **human escalation**
7. Results are saved back to the PO and logged in the audit trail

### Fiori UI

The UI is built with **SAP Fiori Elements** — annotation-driven, no manual UI coding for standard views:

#### Pages

| Page | Template | Key Annotations |
|:---|:---|:---|
| **List Report** | `sap.fe.templates.ListReport` | `@UI.SelectionFields`, `@UI.LineItem` |
| **Object Page** | `sap.fe.templates.ObjectPage` | `@UI.HeaderInfo`, `@UI.Facets`, `@UI.FieldGroup` |
| **Custom AI Section** | Controller Extension + Fragment | Custom XML fragment with `sap.fe.macros.Field` |

#### Key Annotations

| Annotation | Purpose |
|:---|:---|
| `@Common.SideEffects` | Auto-refresh fields when related data changes |
| `@Core.OperationAvailable` | Show/hide action buttons based on entity state |
| `@Common.ValueList` | F4 dropdown help for form fields |
| `@Common.ValueCriticality` | Color-code status values (green/orange/red) |

### Security

Role-based access control using **XSUAA**:

| Role | Permissions |
|:---|:---|
| **Viewer** | Read-only access to POs, vendors, products |
| **Procurer** | Create/edit POs, trigger AI reviews |
| **Manager** | Approve/reject POs, view AI reasoning |
| **admin** | Full access — delete, blacklist vendors, reset AI reviews |

---

## 📅 Implementation Plan

A 5-week phased development approach:

| Week | Focus | Deliverables |
|:---|:---|:---|
| **Week 1** | 🏗️ Foundation | `db/schema.cds` — all entities, service definitions, basic handlers, `cds watch` testing |
| **Week 2** | ⚙️ Business Logic | Draft handling, ApprovePO/RejectPO actions, soft delete, SideEffects & OperationAvailable annotations |
| **Week 3** | 🤖 AI Agents | `agents/state.js`, `agents/tools.js`, all 4 agent implementations, orchestrator graph, wire into CAP |
| **Week 4** | 🎨 Fiori UI | List Report, Object Page, custom AI section, manifest.json routing |
| **Week 5** | 🚀 Production | XSUAA, remote services, messaging events, `mta.yaml`, deploy to BTP trial |

---

## ☁️ BTP Services Used

| Service | Category | Usage in PharmaProcure AI |
|:---|:---|:---|
| **SAP HANA Cloud** | Database | Production database with HDI containers |
| **XSUAA** | Security | Authentication & role-based authorization |
| **Application Router** | Security | Entry point, auth flow management |
| **SAP Event Mesh** | Messaging | Pub/sub for PO approval & delivery events |
| **HTML5 App Repository** | Frontend | Hosts Fiori application static files |
| **Application Logging** | Monitoring | Debug & monitor app behavior in production |
| **Audit Logging** | Compliance | Logs every PO approval/rejection and AI decision |
| **Notification Service** | UX | Alerts managers when AI review completes |
| **Connectivity Service** | Integration | Secure tunnel to on-premise S/4HANA |
| **Destination Service** | Integration | Centralized endpoint configuration |
| **Portal / Work Zone** | UX | Fiori Launchpad with role-based tiles |
| **CI/CD Service** | DevOps | Automated build/test/deploy pipelines |

---

## ✅ Feature Coverage Map

### CAP Features Used

| Feature | Where Used |
|:---|:---|
| Entities + Compositions | POs → POItems, ComplianceChecks |
| Aspects (`managed`, `cuid`) | Every entity |
| Custom Types + Enums | POStatus, RiskLevel, AgentDecision |
| `@odata.draft.enabled` | PurchaseOrders entity |
| Projections + `excluding` | VendorsList hides sensitive fields |
| Calculated fields | `lineTotal`, `availableBudget` |
| BEFORE handler | Validation on CREATE/UPDATE |
| ON handler (with `next()`) | READ with virtual fields |
| ON handler (without `next()`) | ApprovePO, RunAIReview, DELETE |
| AFTER handler | Enrich `statusLabel` after READ |
| Soft Delete | DELETE → UPDATE `isDeleted=true` |
| Bound Actions | ApprovePO, RejectPO, RunAIReview |
| Unbound Actions | BulkApprove |
| Unbound Functions | GetBudgetSummary, GetVendorScore |
| `@restrict` (row-level) | POs entity access control |
| `@requires` (service-level) | ProcurementService, AdminService |
| Remote Service | VendorVerificationAPI |
| Messaging / Events | POApproved, VendorDeliveryConfirmed |
| `@Common.SideEffects` | Vendor change, item change, actions |
| `@Core.OperationAvailable` | All action buttons |
| `@Common.ValueList` | Vendor F4 dropdown |
| Analytics (aggregations) | AnalyticsService with GROUP BY |
| MTA deployment | mta.yaml with all BTP services |

### LangGraph Features Used

| Feature | Where Used |
|:---|:---|
| `StateGraph` | POReview multi-agent graph |
| `Annotation` (custom state) | POReviewState with all results |
| `MessagesAnnotation` | Message history in state |
| Nodes | 6 nodes (4 agents + final + human) |
| Normal Edges | agents → finalDecision |
| Conditional Edges | shouldEscalate after finalDecision |
| Parallel Execution | All 4 agents start together |
| `ToolNode` | In each agent's ReAct loop |
| Custom Tools | 5 tools querying CAP database |
| `SqliteSaver` (Checkpoint) | Persistent memory per thread_id |
| Thread ID | Per PO per review session |
| Multi-Agent Orchestration | Orchestrator coordinates all agents |
| Human-in-the-loop | humanEscalationNode |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Run `cds watch` and test locally before pushing
- Follow CDS modeling best practices (aspects, compositions)
- All AI agent changes must include updated tool schemas
- Test handler logic with `cds test` before deploying
- Keep annotations in separate `-annotations.cds` files

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ on SAP BTP**

CAP Node.js · Fiori Elements · LangGraph.js · HANA Cloud

</div>
