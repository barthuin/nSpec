# /plan-workflow

Given enriched requirements in `changes/$ARGUMENTS/requirements.md`:

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

1. Read the requirements file
2. Load @specs/base-standards.mdc, @specs/workflow-patterns.mdc, @specs/node-standards.mdc
3. Use the **`n8n-workflow-patterns`** skill to select the right architectural
   pattern and identify standard building blocks
4. Act as the **workflow-architect** agent
5. **Community node check** — for each external service mentioned in the requirements:
   - Run `search_nodes(query: "<service>", source: "community")`
   - If a verified or widely-used community node exists, **use it in the plan** instead of `httpRequest`
   - In the node list, mark community nodes with `[community]` and include the package name
   - In the Credentials section, add installation instructions for any community node:
     `Settings → Community Nodes → Install Node → <package-name>`
6. Design the complete workflow architecture
7. Save the plan to `changes/$ARGUMENTS/plan.md`

The plan must include:
- [ ] Trigger type and configuration
- [ ] Node list (type, name, purpose, connections)
- [ ] Data flow description
- [ ] Credentials required
- [ ] Error handling strategy
- [ ] Test scenarios (happy path + edge cases)

Do NOT generate any n8n JSON yet. Plan only.
