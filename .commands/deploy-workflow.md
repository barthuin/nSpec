# /deploy-workflow

Given a validated workflow in `changes/$ARGUMENTS/workflow.json`:

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
