# /review-workflow

Given a workflow JSON in `changes/$ARGUMENTS/workflow.json`:

1. Read the workflow JSON
2. Read `changes/$ARGUMENTS/plan.md` and `changes/$ARGUMENTS/requirements.md`
3. Load @base-standards.mdc, @node-standards.mdc, @workflow-patterns.mdc, @error-standards.mdc
4. **Skill check — run before continuing:**
   - Search for nodes with `"type": "n8n-nodes-base.code"` in workflow.json
   - If ≥ 1 Code node found → load skill **`n8n-code-javascript`**
   - If no Code nodes → do NOT load that skill (saves ~18,500 tokens)
   - Always load skill **`n8n-mcp-tools-expert`**
5. Act as the **workflow-reviewer** agent
6. Perform a deep review covering:

## Review Checklist

### Structural Compliance
- [ ] Workflow name follows `[TRIGGER_TYPE]-[DOMAIN]-[ACTION]` convention
- [ ] Error Trigger node present and connected to a notification node
- [ ] Architecture follows the standard pattern (Trigger → Validate → Transform → Action → Notify)
- [ ] All nodes have descriptive names (no default "HTTP Request1" names)
- [ ] Every non-trivial node has a sticky note

### Logic & Correctness
- [ ] Workflow actually solves what the requirements describe
- [ ] All data paths from the plan are implemented
- [ ] No dead-end nodes (nodes with no outgoing connections except terminal ones)
- [ ] IF/Switch nodes have a fallback/default branch
- [ ] Loops have an explicit exit condition

### Security & Credentials
- [ ] No hardcoded tokens, API keys, or passwords
- [ ] All credentials use n8n credential store
- [ ] Credential names follow `[SERVICE]-[ENV]-[PURPOSE]` convention
- [ ] No PII logged or stored unnecessarily

### Resilience
- [ ] HTTP Request nodes have timeouts configured
- [ ] HTTP 4xx and 5xx responses are handled explicitly
- [ ] External service calls have retry logic or error handling
- [ ] AI Agent outputs are validated before downstream use

### Code Nodes
- [ ] Each Code node is under 50 lines
- [ ] Returns correct array format `[{json: {...}}]`
- [ ] No expression syntax `{{}}` inside Code nodes
- [ ] Null checks present for fields that may be missing

### AI Agents (if present)
- [ ] System prompt has Role, Task, Output Format, Constraints
- [ ] Only minimum necessary tools are exposed
- [ ] Output validation node follows the AI Agent node
- [ ] Irreversible actions have human-in-the-loop step

6. Output a report to `changes/$ARGUMENTS/review.md`:

```markdown
# Review: {WF-ID}

## Result: APPROVED / NEEDS CHANGES

## Issues Found

### Critical (must fix before deploy)
- [node name] — description of issue — suggested fix

### Warnings (should fix)
- [node name] — description — suggestion

### Suggestions (nice to have)
- [node name] — description — suggestion

## Summary
```

7. If NEEDS CHANGES: list the exact nodes and properties to modify
8. Do NOT modify the workflow.json — only report issues
