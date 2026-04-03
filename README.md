# nSpec

> **Spec it. Generate it. Run it.**

## What is nSpec?

**nSpec** (**n**ode **Spec**ification Framework) is a Spec-Driven Development (SDD) framework for building n8n automation workflows using AI agents.

It bridges human intent and machine execution: you write a specification, AI agents interpret it, and n8n runs it. The spec is the source of truth — the workflow is just its materialization.

```
Human intent → Spec → Agent → Workflow → Execution
```

nSpec is a **Spec-Driven AI Workflow Orchestration Framework**. It enables developers to define automation workflows as structured specifications, which are then interpreted, generated, and deployed as executable n8n workflows by any AI coding agent.

---

## Prerequisites

- An AI coding agent (see [Supported agents](#supported-agents))
- An n8n instance (local or cloud)
- The [n8n-mcp](https://github.com/czlonkowski/n8n-mcp) MCP server configured in your agent

---

## Getting Started

### 1. Copy nSpec into your project

```bash
git clone https://github.com/barthuin/nSpec.git
cp -r nSpec/{CLAUDE.md,AGENTS.md,.claude,templates,changes} your-project/
```

Or use the repo directly as your working directory.

### 2. Pick your flow

nSpec has two entry points depending on your context:

---

#### Flow A — Team (a PO or client writes the requirements)

```
/init-workflow WF-001
```
Select **Flow A**. Claude creates `changes/WF-001/` and copies the requirements template.
Open `changes/WF-001/requirements.md`, fill in the workflow description, then:

```
/enrich-workflow-spec WF-001
```
Claude adds missing technical details to the requirements.

---

#### Flow B — Freelance (you talk directly to the client)

```
/init-workflow WF-001
```
Select **Flow B**. Claude creates `changes/WF-001/` and copies the client-notes template.
Paste the raw client input (meeting notes, email, WhatsApp — anything) into `changes/WF-001/client-notes.md`, then:

```
/capture-requirements WF-001
```
Claude asks clarifying questions if needed, then generates a fully structured and technically enriched `requirements.md` in one step — no need to run `/enrich-workflow-spec` after.

Optionally create the ticket in your project management tool:

```
/create-ticket WF-001
```
Creates a Jira or Notion ticket from `requirements.md` and updates the file with the ticket ID.

---

### 3. Run the development pipeline

From here both flows converge:

```
/plan-workflow WF-001
```
The `workflow-architect` agent designs the full node architecture. Review `changes/WF-001/plan.md` and approve it before continuing.

```
/clear
```
Resets the conversation context. State is preserved on disk in `changes/WF-001/`.

```
/build-workflow WF-001
```
The `node-developer` agent builds the workflow JSON node by node, validating each one with n8n MCP tools.

```
/clear
```
Resets context again before QA — unloads the heavy build skills (~27k tokens).

```
/validate-workflow WF-001
```
Automated compliance check against all nSpec standards.

```
/review-workflow WF-001
```
Deep review from a senior developer perspective: logic, security, resilience. Generates `changes/WF-001/review.md` with any issues.

```
/deploy-workflow WF-001
```
Deploys to your n8n instance via MCP.

```
/document-workflow WF-001
```
Generates `changes/WF-001/README.md` with full documentation.

---

## Full Directory Structure

```
your-project/
├── CLAUDE.md                     # Entry point for Claude Code — loads all specs
├── AGENTS.md                     # Entry point for other AI tools (Cursor, Copilot, etc.)
│
├── .claude/                      # Claude Code configuration (auto-discovered)
│   ├── specs/                    # Standards (single source of truth)
│   │   ├── base-standards.mdc        # Core rules and naming conventions
│   │   ├── node-standards.mdc        # Per-node configuration rules
│   │   ├── workflow-patterns.mdc     # Architectural patterns (webhook, schedule, AI agent...)
│   │   ├── credential-standards.mdc  # How to handle credentials safely
│   │   ├── ai-agent-standards.mdc    # Rules for AI Agent nodes
│   │   ├── testing-standards.mdc     # Test scenario structure and checklist
│   │   └── error-standards.mdc       # Error categories, retry policy, notification format
│   │
│   ├── agents/                   # AI agent role definitions
│   │   ├── workflow-architect.md     # Designs architecture — never implements
│   │   ├── ai-agent-builder.md       # Configures AI Agent nodes
│   │   ├── node-developer.md         # Implements node by node
│   │   ├── integration-specialist.md # Designs external service connections
│   │   └── workflow-reviewer.md      # Reviews JSON against all standards
│   │
│   ├── commands/                 # Slash commands for Claude Code
│   │   ├── init-workflow.md          # Create changes folder and copy templates
│   │   ├── enrich-workflow-spec.md   # Add technical detail to raw requirements
│   │   ├── plan-workflow.md          # Generate architecture plan
│   │   ├── build-workflow.md         # Build workflow JSON from plan
│   │   ├── validate-workflow.md      # Automated standards validation
│   │   ├── review-workflow.md        # Deep review with actionable fixes
│   │   ├── deploy-workflow.md        # Deploy to n8n instance
│   │   ├── document-workflow.md      # Generate README documentation
│   │   ├── debug-workflow.md         # Debug failing workflows
│   │   └── iterate-workflow.md       # Modify existing deployed workflows
│   │
│   └── skills/                   # Specialized knowledge libraries
│       ├── n8n-code-javascript/      # How to write JS in Code nodes (~18,500 tokens)
│       ├── n8n-workflow-patterns/    # Proven architectural patterns (~18,300 tokens)
│       └── n8n-mcp-tools-expert/     # How to use n8n MCP tools effectively (~8,300 tokens)
│
├── templates/                    # Input templates for commands
│   ├── client-notes.md           # Flow B: paste raw client input here
│   ├── requirements.md           # Flow A: fill in structured requirements
│   ├── debug-request.md          # Start here to debug a workflow
│   └── iteration-request.md      # Start here to modify a workflow
│
└── changes/                      # One folder per workflow
    └── {WF-ID}/
        ├── config.md             # Language preference (written by /init-workflow)
        ├── client-notes.md       # Flow B input: raw client notes
        ├── requirements.md       # Structured spec (input for /plan-workflow)
        ├── plan.md               # Output of /plan-workflow
        ├── workflow.json         # Output of /build-workflow
        ├── review.md             # Output of /review-workflow
        └── README.md             # Output of /document-workflow
```

---

## Command Reference

### Setup (both flows)

| Command | Input | What it does |
|---------|-------|-------------|
| `/init-workflow {WF-ID}` | — | Creates `changes/{WF-ID}/` and copies the right template |

### Flow A — Team

| Command | Input | What it does |
|---------|-------|-------------|
| `/enrich-workflow-spec {WF-ID}` | `requirements.md` filled by PO | Adds missing technical details |
| `/plan-workflow {WF-ID}` | enriched `requirements.md` | Designs complete node architecture |
| `/build-workflow {WF-ID}` | approved `plan.md` | Generates workflow JSON |
| `/validate-workflow {WF-ID}` | `workflow.json` | Automated standards compliance check |
| `/review-workflow {WF-ID}` | `workflow.json` | Deep review: logic, security, resilience |
| `/deploy-workflow {WF-ID}` | validated `workflow.json` | Deploys to n8n via MCP |
| `/document-workflow {WF-ID}` | all of the above | Generates full documentation |

### Flow B — Freelance

| Command | Input | What it does |
|---------|-------|-------------|
| `/capture-requirements {WF-ID}` | `client-notes.md` (raw text) | Structures + enriches requirements in one step |
| `/create-ticket {WF-ID}` | `requirements.md` | Creates Jira / Notion ticket with technical details |

Then continues with `/plan-workflow` onwards (same as Flow A).

### Maintenance

| Command | When to use | Requires |
|---------|------------|---------|
| `/debug-workflow {WF-ID}` | Workflow fails in production | `changes/{WF-ID}/debug-request.md` |
| `/iterate-workflow {WF-ID}` | Need to modify a deployed workflow | `changes/{WF-ID}/iteration-request.md` |

---

## Agents

Agents are specialized AI roles. Commands activate them automatically — you don't invoke agents directly.

| Agent | Responsibility | Never does |
|-------|---------------|-----------|
| `workflow-architect` | Designs node structure and data flow | Write JSON |
| `ai-agent-builder` | Configures AI Agent nodes and tool definitions | Build non-AI nodes |
| `node-developer` | Implements every node per the approved plan | Design decisions |
| `integration-specialist` | Maps external service connections and auth | Implementation |
| `workflow-reviewer` | Reviews JSON for issues before deploy | Modify files |

---

## Key Standards

### Workflow naming
```
[TRIGGER_TYPE]-[DOMAIN]-[ACTION]

webhook-lead-qualify
schedule-invoice-send
manual-crm-sync
```

### Mandatory architecture
```
[Trigger] → [Validate/Filter] → [Transform] → [Action(s)] → [Success notify]
                                                          ↘ [Error handler]
```

### Credential naming
```
[SERVICE]-[ENVIRONMENT]-[PURPOSE]

openai-prod-agents
slack-staging-notifications
postgres-prod-main
```

### Error categories
| Code | Type | Retry? |
|------|------|--------|
| `ERR_CONFIG` | Wrong node setup | No |
| `ERR_DATA` | Bad input shape | No |
| `ERR_AUTH` | Credential failure | No |
| `ERR_INTEGRATION` | External service failure | Yes (3x backoff) |
| `ERR_LOGIC` | Unexpected branch | No |
| `ERR_RESOURCE` | Rate limit / quota | Yes (5x backoff) |

---

## Core Principles

1. **Specs first** — every workflow starts as a spec, never as a blank canvas
2. **Atomic workflows** — one workflow, one responsibility
3. **Error handling is mandatory** — every workflow has an Error Trigger
4. **Idempotency** — workflows must be safely re-runnable
5. **Baby steps** — build and test node by node
6. **Reuse before rebuild** — check patterns and templates before creating from scratch
7. **Never infer** — if it's not in the spec, ask
8. **Agents are specialized** — each agent owns a single responsibility (architect, builder, reviewer, deployer)
9. **Workflows are generated artifacts** — specs are versioned, workflows are derived from them
10. **Logic is declarative** — describe *what* a workflow does, not *how* to configure each node
11. **Automation is deterministic** — the same spec always produces an equivalent workflow

---

## Debugging a Failing Workflow

```bash
cp templates/debug-request.md changes/WF-001/debug-request.md
# Fill in: error message, execution ID, failing node
```

```
/debug-workflow WF-001
```

Claude will fetch the execution log, classify the error type, trace the data flow, and propose a concrete fix.

---

## Modifying a Deployed Workflow

```bash
cp templates/iteration-request.md changes/WF-001/iteration-request.md
# Fill in: what needs to change and why
```

```
/iterate-workflow WF-001
```

Claude will analyze the impact, update the plan, rebuild only what changed, review, and redeploy.

---

## Supported Agents

nSpec works with any AI coding agent that can read project instructions and execute slash commands:

| Config file | Agent |
|-------------|-------|
| `CLAUDE.md` | [Claude Code](https://claude.ai/code) |
| `AGENTS.md` | [GitHub Copilot](https://github.com/features/copilot), [Cursor](https://cursor.sh), [Windsurf](https://codeium.com/windsurf), [Gemini CLI](https://github.com/google-gemini/gemini-cli), OpenAI Codex |

Each agent reads its own config file — both load the same specs, agents, and commands.
MCP tool support (required for `n8n-mcp`) may vary by agent; check your agent's documentation.

---

## Name

**n** → node (n8n ecosystem)
**Spec** → specification-driven development
**nSpec** → sounds like *inspect*: examine intent before building
