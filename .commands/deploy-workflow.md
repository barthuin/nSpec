# /deploy-workflow

Given a validated workflow in `changes/$ARGUMENTS/workflow.json`:

1. Read the workflow JSON
2. Confirm validation has passed (check for `changes/$ARGUMENTS/plan.md` approval)
3. Use `n8n_create_workflow` to deploy to the n8n instance
4. If a workflow with the same name exists, use `n8n_update_full_workflow`
5. Confirm deployment success and retrieve the workflow ID
6. Update `changes/$ARGUMENTS/plan.md` with:
   - Deployed workflow ID
   - Deployment timestamp
   - n8n instance URL

Do NOT deploy if `n8n_validate_workflow` has not been run and passed.
