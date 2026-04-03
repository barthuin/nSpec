# nSpec — n8n Spec-Driven Development Framework

> Generic agent configuration for Cursor, GitHub Copilot, Gemini CLI, Windsurf, and others.
> For Claude Code, see `CLAUDE.md`.

## Standards (single source of truth)

All agents working in this project must apply:

- `specs/base-standards.mdc` — Core rules and naming conventions
- `specs/node-standards.mdc` — Node configuration rules
- `specs/workflow-patterns.mdc` — Architectural patterns
- `specs/credential-standards.mdc` — Credential handling
- `specs/ai-agent-standards.mdc` — AI agent node standards
- `specs/testing-standards.mdc` — Testing rules
- `specs/error-standards.mdc` — Error handling catalog

---

## Development Lifecycle

### Flow A — Team (PO writes requirements)

```
requirements.md → enrich-workflow-spec → plan-workflow → build-workflow
                                                               ↓
                              document-workflow ← deploy-workflow ← validate-workflow
```

| Step | Command | Input | Output |
|------|---------|-------|--------|
| 1 | `enrich-workflow-spec` | `changes/{WF-ID}/requirements.md` | enriched requirements |
| 2 | `plan-workflow` | enriched requirements | `changes/{WF-ID}/plan.md` |
| 3 | `build-workflow` | approved plan | `changes/{WF-ID}/workflow.json` |
| 4 | `validate-workflow` | workflow.json | validation report |
| 5 | `review-workflow` | workflow.json | review with fixes |
| 6 | `deploy-workflow` | validated workflow.json | deployed workflow URL |
| 7 | `document-workflow` | all of the above | `changes/{WF-ID}/README.md` |

### Flow B — Freelance (developer talks directly to client)

```
client-notes.md → capture-requirements → create-ticket → plan-workflow → build-workflow
                                                                               ↓
                                         document-workflow ← deploy-workflow ← validate-workflow
```

| Step | Command | Input | Output |
|------|---------|-------|--------|
| 1 | `capture-requirements` | `changes/{WF-ID}/client-notes.md` | `changes/{WF-ID}/requirements.md` |
| 2 | `create-ticket` | requirements.md | ticket in Jira / Notion + ID in requirements.md |
| 3 | `plan-workflow` | requirements.md | `changes/{WF-ID}/plan.md` |
| 4 | `build-workflow` | approved plan | `changes/{WF-ID}/workflow.json` |
| 5 | `validate-workflow` | workflow.json | validation report |
| 6 | `review-workflow` | workflow.json | review with fixes |
| 7 | `deploy-workflow` | validated workflow.json | deployed workflow URL |
| 8 | `document-workflow` | all of the above | `changes/{WF-ID}/README.md` |

### Maintenance

| Command | When to use |
|---------|-------------|
| `debug-workflow` | Workflow fails in production |
| `iterate-workflow` | Modify an already deployed workflow |

---

## Agent Roles

Defined in `.claude/agents/`. Commands activate the right agent automatically.

| Agent | Responsibility | Never does |
|-------|---------------|-----------|
| `workflow-architect` | Designs node structure and data flow | Write JSON |
| `ai-agent-builder` | Configures AI Agent nodes and tool definitions | Build non-AI nodes |
| `node-developer` | Implements every node per the approved plan | Design decisions |
| `integration-specialist` | Maps external service connections and auth | Implementation |
| `workflow-reviewer` | Reviews JSON for issues before deploy | Modify files |

---

## Skills

Load only when needed to avoid unnecessary context cost.

| Skill | Load when | Approx. size |
|-------|-----------|--------------|
| `.claude/skills/n8n-code-javascript/` | Workflow has Code nodes | ~18,500 tokens |
| `.claude/skills/n8n-workflow-patterns/` | Designing architecture (plan, capture) | ~18,300 tokens |
| `.claude/skills/n8n-mcp-tools-expert/` | build, validate, deploy, review | ~8,300 tokens |

---

## Model Configuration (optional)

By default all commands use the same model. Optionally assign a second, lighter model
to structured tasks to reduce cost. Configure this in your agent's settings.

### Command types

| Type | Commands |
|------|----------|
| **Primary model** — reasoning, code generation | `capture-requirements`, `plan-workflow`, `build-workflow`, `review-workflow`, `debug-workflow`, `iterate-workflow` |
| **Secondary model** — structured, automation | `enrich-workflow-spec`, `create-ticket`, `validate-workflow`, `deploy-workflow`, `document-workflow` |

### Modes

**Single model (default)**
All commands use the same model. No configuration needed.

**Dual model**
Configure your agent to use two models:
- **Primary**: a capable reasoning model (e.g. Claude Sonnet, GPT-4o, Gemini Pro)
- **Secondary**: a faster/cheaper model (e.g. Claude Haiku, GPT-4o mini, Gemini Flash)

Refer to your agent's documentation for multi-model or per-task model routing.

---

## changes/ Structure

```
changes/
└── {WF-ID}/
    ├── config.md         # Language preference: lang: es | en | pt
    ├── client-notes.md   # Flow B: raw client input
    ├── requirements.md   # Structured spec (input for plan-workflow)
    ├── plan.md           # Output of plan-workflow
    ├── workflow.json     # Output of build-workflow
    ├── review.md         # Output of review-workflow
    └── README.md         # Output of document-workflow
```

---

## Core Principles

The spec is the source of truth. The workflow JSON is its materialization.
Never build a workflow without a spec. Never modify a workflow without updating its spec.
