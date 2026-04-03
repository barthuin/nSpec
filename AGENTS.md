# nSpec — n8n Spec-Driven Development Framework

> Generic agent configuration. For Claude Code, see CLAUDE.md.

## Standards (single source of truth)

All AI agents working in this project must apply:

- `.claude/specs/base-standards.mdc` — Core rules and naming conventions
- `.claude/specs/node-standards.mdc` — Node configuration rules
- `.claude/specs/workflow-patterns.mdc` — Architectural patterns
- `.claude/specs/credential-standards.mdc` — Credential handling
- `.claude/specs/ai-agent-standards.mdc` — AI agent node standards
- `.claude/specs/testing-standards.mdc` — Testing rules
- `.claude/specs/error-standards.mdc` — Error handling catalog

## Agent Roles

Defined in `.claude/agents/`:

- `workflow-architect.md` — Architecture design only, no implementation
- `ai-agent-builder.md` — AI Agent node configuration
- `node-developer.md` — Node-by-node implementation
- `integration-specialist.md` — External service integrations
- `workflow-reviewer.md` — Code review against standards

## Commands

Defined in `.claude/commands/`:

| Command file | Purpose |
|---|---|
| `enrich-workflow-spec.md` | Add technical detail to raw requirements |
| `plan-workflow.md` | Generate architecture plan |
| `build-workflow.md` | Build workflow JSON from plan |
| `validate-workflow.md` | Automated validation against standards |
| `review-workflow.md` | Deep review with actionable fixes |
| `deploy-workflow.md` | Deploy to n8n instance |
| `document-workflow.md` | Generate README documentation |
| `debug-workflow.md` | Debug failing workflows |
| `iterate-workflow.md` | Modify existing deployed workflows |

## Development Lifecycle

1. Create `changes/{WF-ID}/requirements.md` (use `templates/requirements.md`)
2. Enrich → Plan → Build → Validate → Review → Deploy → Document

## Core Principle

The spec is the source of truth. The workflow JSON is its materialization.
Never build a workflow without a spec. Never modify a workflow without updating its spec.
