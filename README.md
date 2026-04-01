# nSpec

> **Spec it. Generate it. Run it.**

## What is nSpec?

**nSpec** (**n**ode **Spec**ification Framework) is a Spec-Driven Development
framework for building n8n automation workflows using AI agents.

It bridges human intent and machine execution: you write a specification,
AI agents interpret it, and n8n runs it. The spec is the source of truth —
the workflow is just its materialization.

```
Human intent → Spec → Agent → Workflow → Execution
```

## Framework Definition

nSpec is a **Spec-Driven AI Workflow Orchestration Framework**.

It enables developers to define automation workflows as structured
specifications, which are then interpreted, generated, and deployed
as executable n8n workflows by specialized AI agents (Claude Code).

## Core Principles

- **Specs are the source of truth** — every workflow starts as a spec,
  never as a blank canvas
- **Agents are specialized** — each agent owns a single responsibility
  (architect, builder, validator, deployer)
- **Workflows are generated artifacts** — specs are versioned, workflows
  are derived from them
- **Integrations are reusable** — nodes, credentials, and patterns are
  abstracted as composable building blocks
- **Logic is declarative** — you describe *what* a workflow does,
  not *how* to configure each node
- **Automation is deterministic** — the same spec always produces
  an equivalent workflow
- **Development is incremental** — one spec, one agent, one workflow at a time

## Name

**n** → node (n8n ecosystem)
**Spec** → specification-driven development
**nSpec** → sounds like *inspect*: examine intent before building
