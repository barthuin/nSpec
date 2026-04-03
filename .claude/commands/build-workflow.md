# /build-workflow

Given an approved plan in `changes/$ARGUMENTS/plan.md`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read the plan file
2. Load @.claude/specs/node-standards.mdc and @.claude/specs/credential-standards.mdc as context
3. **Skill check — run before continuing:**
   - Count how many `code` type nodes appear in the plan
   - If ≥ 1 Code node → load skill **`n8n-code-javascript`**
   - If no Code nodes → do NOT load that skill (saves ~18,500 tokens)
   - Always load skill **`n8n-mcp-tools-expert`**
4. Act as the **node-developer** agent
5. For each node in the plan:
   a. Use **`n8n-mcp-tools-expert`** skill → `search_nodes` to confirm the correct node type
   b. Configure the node following @.claude/specs/node-standards.mdc
   c. Use **`n8n-mcp-tools-expert`** skill → `validate_node` to validate
   d. For Code nodes: use **`n8n-code-javascript`** skill for implementation
6. Search for similar templates: `search_templates`
7. Assemble the complete workflow JSON
8. Validate the full workflow: `n8n_validate_workflow`
9. Save to `changes/$ARGUMENTS/workflow.json`

Do NOT deploy yet. Save and report validation result.
