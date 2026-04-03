# /enrich-workflow-spec

Given a raw workflow idea or requirement in `changes/$ARGUMENTS/requirements.md`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read the requirements file
2. Load @.claude/specs/base-standards.mdc and @.claude/specs/workflow-patterns.mdc as context
3. Assess completeness — a good spec must include:
   - Trigger type and origin
   - Input data description
   - Expected output or side effects
   - Integrations involved
   - Error scenarios
   - Acceptance criteria
4. Enrich the requirements file with missing technical details
5. Mark original content as `[original]` and additions as `[enriched]`
6. Save the enriched version back to `changes/$ARGUMENTS/requirements.md`

Do NOT design the workflow yet. Only enrich the specification.
