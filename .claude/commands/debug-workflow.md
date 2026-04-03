# /debug-workflow

Debug a failing or misbehaving workflow.

**Usage**: `/debug-workflow {WF-ID}`

The file `changes/$ARGUMENTS/debug-request.md` must exist with at least:
- Workflow ID or name in n8n
- Error message or unexpected behavior description
- (Optional) execution ID from n8n

## Process

1. Read `changes/$ARGUMENTS/debug-request.md`
2. Read `changes/$ARGUMENTS/workflow.json` (current version)
3. Read `changes/$ARGUMENTS/plan.md` if available
4. Load @.claude/specs/base-standards.mdc, @.claude/specs/node-standards.mdc, @.claude/specs/error-standards.mdc

### Phase 0 — Language & Skills

**Language**: Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

**Skills**: Determine which skills to load before proceeding:
- Check debug-request.md for the failing node name/type
- If the failing node is a Code node → load skill **`n8n-code-javascript`**
- If not a Code node → do NOT load that skill (saves ~18,500 tokens)
- Always load skill **`n8n-mcp-tools-expert`**

### Phase 1 — Gather Information

Use **`n8n-mcp-tools-expert`** skill for all MCP operations in this phase:

5. If execution ID provided: use `n8n_executions` to fetch execution details
6. If workflow ID provided: use `n8n_get_workflow` to get the live version
7. Identify the failing node and the error type

### Phase 2 — Diagnose

8. Classify the error using @.claude/specs/error-standards.mdc categories:
   - **Config error**: wrong node configuration (type mismatch, missing field)
   - **Data error**: unexpected input shape or missing data
   - **Auth error**: credential or permission issue
   - **Integration error**: external service failure or timeout
   - **Logic error**: wrong branching or data transformation

9. Trace the data flow backwards from the failing node:
   - What data was expected?
   - What data was received?
   - Where did the divergence happen?

### Phase 3 — Fix Plan

10. Propose a concrete fix for each issue found
11. If the fix requires changing the spec, note it explicitly
12. Save diagnosis to `changes/$ARGUMENTS/debug-report.md`:

```markdown
# Debug Report: {WF-ID}

## Error Summary
- Failing node: ...
- Error type: config | data | auth | integration | logic
- Root cause: ...

## Data Trace
Description of what data was at each step.

## Fixes Required

### Fix 1 — [Node Name]
- Problem: ...
- Root cause: ...
- Change required: ...
- Node property to update: ...

## Spec Changes Required (if any)
List any spec updates needed before re-building.
```

### Phase 4 — Apply Fixes

13. Ask for confirmation before modifying `workflow.json`
14. If the fix involves a Code node: use **`n8n-code-javascript`** skill
    to implement the corrected version
15. If confirmed: apply the fixes and use **`n8n-mcp-tools-expert`** skill
    → `n8n_validate_workflow`
16. If validation passes: offer to deploy with `/deploy-workflow`
