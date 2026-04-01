# /build-workflow

Given an approved plan in `changes/$ARGUMENTS/plan.md`:

1. Read the plan file
2. Load @node-standards.mdc as context
3. Act as the **node-developer** agent
4. For each node in the plan:
   a. Use `search_nodes` to confirm the correct node type
   b. Configure the node following @node-standards.mdc
   c. Validate with `validate_node`
5. Search for similar templates: `search_templates`
6. Assemble the complete workflow JSON
7. Validate the full workflow: `n8n_validate_workflow`
8. Save to `changes/$ARGUMENTS/workflow.json`

Do NOT deploy yet. Save and report validation result.
