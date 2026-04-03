# /validate-workflow

Given a workflow JSON in `changes/$ARGUMENTS/workflow.json`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read the workflow JSON
2. Load @.claude/specs/base-standards.mdc and @.claude/specs/node-standards.mdc
3. Use **`n8n-mcp-tools-expert`** skill → run `n8n_validate_workflow` on the JSON
4. Check compliance against standards:
   - [ ] Workflow name follows naming convention
   - [ ] Error Trigger node present and connected
   - [ ] No hardcoded credentials
   - [ ] All nodes have descriptive names
   - [ ] Non-trivial nodes have sticky notes
   - [ ] All IF/Switch branches are documented
5. Report: PASSED / FAILED with details
6. If FAILED, list issues with node references and suggested fixes
