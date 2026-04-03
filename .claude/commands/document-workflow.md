# /document-workflow

Given a deployed workflow in `changes/$ARGUMENTS/`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read `requirements.md`, `plan.md`, and `workflow.json`
2. Generate a `changes/$ARGUMENTS/README.md` with:

```markdown
# {Workflow Name}

## Purpose
One paragraph describing what this workflow does and why.

## Trigger
How and when the workflow is triggered.

## Flow Summary
Step-by-step description of the workflow logic.

## Integrations
List of external services used with auth method.

## Credentials Required
| Service | Credential Name | Scopes |
|---------|----------------|--------|

## Input / Output
Description of expected input data and produced output.

## Error Handling
What happens when the workflow fails.

## Test Scenarios
How to test this workflow manually.

## Deployment Info
- Workflow ID: ...
- n8n instance: ...
- Last deployed: ...
```
