# /plan-workflow

Given enriched requirements in `changes/$ARGUMENTS/requirements.md`:

1. Read the requirements file
2. Load @base-standards.mdc, @workflow-patterns.mdc, @node-standards.mdc
3. Act as the **workflow-architect** agent
4. Design the complete workflow architecture
5. Save the plan to `changes/$ARGUMENTS/plan.md`

The plan must include:
- [ ] Trigger type and configuration
- [ ] Node list (type, name, purpose, connections)
- [ ] Data flow description
- [ ] Credentials required
- [ ] Error handling strategy
- [ ] Test scenarios (happy path + edge cases)

Do NOT generate any n8n JSON yet. Plan only.
