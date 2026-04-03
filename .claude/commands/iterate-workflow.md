# /iterate-workflow

Modify an existing deployed workflow while keeping spec and implementation in sync.

**Usage**: `/iterate-workflow {WF-ID}`

The file `changes/$ARGUMENTS/iteration-request.md` must exist with:
- What needs to change (new requirement or bug fix)
- Why it needs to change
- Scope: additive (new nodes) | modification (change existing) | removal

## Process

### Phase 0 — Language & Skills

**Language**: Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

**Skills**: Determine which skills to load before proceeding:
- Read `changes/$ARGUMENTS/iteration-request.md` — identify which nodes are affected
- If any affected node is a Code node → load skill **`n8n-code-javascript`**
- If no Code nodes are involved → do NOT load that skill (saves ~18,500 tokens)
- Always load skill **`n8n-mcp-tools-expert`**

### Phase 1 — Understand Current State

1. Read `changes/$ARGUMENTS/iteration-request.md`
2. Read `changes/$ARGUMENTS/plan.md` (current architecture)
3. Read `changes/$ARGUMENTS/requirements.md` (original requirements)
4. If workflow is deployed: use `n8n_get_workflow` to get the live version
   - Compare live version against `workflow.json` — flag any divergence
5. Load @specs/base-standards.mdc, @specs/workflow-patterns.mdc, @specs/node-standards.mdc

### Phase 2 — Impact Analysis

6. Identify which nodes are affected by the requested change
7. Identify downstream effects (nodes that depend on changed data)
8. Classify the change:
   - **Additive**: new nodes, new branches, new integrations
   - **Modification**: changing node config, data transformation, conditions
   - **Removal**: removing nodes or simplifying flow

9. Save impact analysis as a section in `changes/$ARGUMENTS/iteration-request.md`

### Phase 3 — Update Plan

10. Act as the **workflow-architect** agent
11. Update `changes/$ARGUMENTS/plan.md` with the new or modified nodes
12. Mark changed sections with `[ITERATION]` tag
13. Do NOT re-plan unchanged sections — preserve what works

### Phase 4 — Implement Changes

14. Act as the **node-developer** agent
15. For each changed node:
    a. Use **`n8n-mcp-tools-expert`** skill → `validate_node` on current config
    b. Apply the change
    c. For Code nodes: use **`n8n-code-javascript`** skill for implementation
    d. Use **`n8n-mcp-tools-expert`** skill → `validate_node` on updated config
16. Assemble the updated workflow JSON
17. Use **`n8n-mcp-tools-expert`** skill → `n8n_validate_workflow` on full workflow
18. Save to `changes/$ARGUMENTS/workflow.json` (overwrite)

### Phase 5 — Review & Deploy

19. Run `/review-workflow {WF-ID}` before deploying
20. If APPROVED: use `n8n_update_full_workflow` to update the live workflow
21. Update `changes/$ARGUMENTS/plan.md` with new deployment info
22. Update `changes/$ARGUMENTS/README.md` with change history entry:

```markdown
## Change History

### {DATE} — {Short description}
- Changed: [list of modified nodes]
- Reason: [from iteration-request.md]
- Deployed: [workflow URL or ID]
```
