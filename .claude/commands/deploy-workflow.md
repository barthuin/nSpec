# /deploy-workflow

Given a validated workflow in `changes/$ARGUMENTS/workflow.json`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read the workflow JSON
2. Confirm validation has passed (check for `changes/$ARGUMENTS/plan.md` approval)
3. Use **`n8n-mcp-tools-expert`** skill for all deployment operations:
   - `n8n_create_workflow` to deploy to the n8n instance
   - `n8n_update_full_workflow` if a workflow with the same name already exists
4. Confirm deployment success and retrieve the workflow ID
5. Update `changes/$ARGUMENTS/plan.md` with:
   - Deployed workflow ID
   - Deployment timestamp
   - n8n instance URL

Do NOT deploy if `n8n_validate_workflow` has not been run and passed.
