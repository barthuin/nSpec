# /create-ticket

Creates a ticket in the client's project management tool from a structured `requirements.md`.

**Input**: `changes/$ARGUMENTS/requirements.md`
**Output**: ticket created + `requirements.md` updated with the ticket ID

## Process

### Phase 0 — Language

Read `changes/$ARGUMENTS/config.md`:
- `lang: es` → respond in **Spanish** throughout
- `lang: pt` → respond in **Portuguese** throughout
- `lang: en` or file missing → respond in **English** (default)

> Exception: node names, variables, expressions, code, and JSON keys always remain in English (n8n requirement).

### Phase 1 — Read requirements

1. Read `changes/$ARGUMENTS/requirements.md`
2. Verify the file exists and is complete (must have at least Problem Statement,
   Trigger, and Acceptance Criteria). If any are missing, stop and report:
   "Run `/capture-requirements $ARGUMENTS` first."

### Phase 2 — Detect available tool

3. Ask the user which tool to use if no default is configured:

   - **Jira** → use `mcp__atlassian__createJiraIssue`
   - **Notion** → use `mcp__claude_ai_Notion__notion-create-pages`
   - **Markdown only** → generate the ticket as formatted text ready to copy

   If only one MCP tool is available, use it directly without asking.

### Phase 3 — Prepare ticket content

4. Generate the ticket content with this structure:

**Title**: `[n8n] {workflow name} — {short action verb}`
- Example: `[n8n] Webhook lead qualify — Qualify incoming leads from Typeform`

**Description**:
```
## Context
{Problem Statement from requirements.md}

## What it must do
{Expected Output / Side Effects}

## Trigger
{Type and configuration}

## Required integrations
{External Integrations table}

## Acceptance criteria
{Acceptance Criteria list as checklist}

## Technical notes
{Technical Notes from requirements.md}

## Out of scope
{Out of Scope}
```

**Type**: Task or Story (depending on the tool)
**Labels**: `n8n`, `automation`, `workflow`
**Estimate**: leave blank — for the developer to fill in

### Phase 4 — Create the ticket

#### If Jira:
5. Ask the user for:
   - Project key (e.g. `PROJ`, `WF`, `AUTO`)
   - Issue type: `Task` or `Story`
6. Run `mcp__atlassian__createJiraIssue` with the prepared content
7. Retrieve the generated issue key (e.g. `PROJ-42`)

#### If Notion:
5. Ask for the Notion database URL where the page should be created
6. Run `mcp__claude_ai_Notion__notion-create-pages` with the prepared content
7. Retrieve the page ID or URL

#### If markdown only:
5. Display the formatted ticket ready to copy and paste manually

### Phase 5 — Update requirements.md

8. Add to the top of `changes/$ARGUMENTS/requirements.md`:

```markdown
> **Ticket**: {TICKET-ID} — {ticket URL}
> **Created**: {date}
```

9. Report to the user:
   "Ticket created: {URL}
   Next step: `/plan-workflow $ARGUMENTS`"

### Phase 6 — Rename folder (optional)

10. Ask: "Do you want to rename `changes/$ARGUMENTS/` to `changes/{TICKET-ID}/`
    to align with the ticket ID?"
11. If yes: rename the folder and update internal references
    in `requirements.md` and `plan.md` if they exist

## Required MCP tools

| Tool | MCP |
|------|-----|
| Jira | `mcp__atlassian__createJiraIssue` |
| Notion | `mcp__claude_ai_Notion__notion-create-pages` |
| No tool | markdown output to console |
