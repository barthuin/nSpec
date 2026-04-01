# /validate-workflow

Given a workflow JSON in `changes/$ARGUMENTS/workflow.json`:

1. Read the workflow JSON
2. Load @base-standards.mdc and @node-standards.mdc
3. Run `n8n_validate_workflow` on the JSON
4. Check compliance against standards:
   - [ ] Workflow name follows naming convention
   - [ ] Error Trigger node present and connected
   - [ ] No hardcoded credentials
   - [ ] All nodes have descriptive names
   - [ ] Non-trivial nodes have sticky notes
   - [ ] All IF/Switch branches are documented
5. Report: PASSED / FAILED with details
6. If FAILED, list issues with node references and suggested fixes
