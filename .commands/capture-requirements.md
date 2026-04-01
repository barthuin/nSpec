# /capture-requirements

Converts raw client notes into a structured, technically enriched `requirements.md`.
Equivalent to filling the template + running `/enrich-workflow-spec` in a single step.

**Input**: `changes/$ARGUMENTS/client-notes.md`
**Output**: `changes/$ARGUMENTS/requirements.md`

## Process

### Phase 0 — Skill check

- Load @base-standards.mdc and @workflow-patterns.mdc
- Load skill **`n8n-workflow-patterns`** to identify the right architectural pattern

### Phase 1 — Read and understand

1. Read `changes/$ARGUMENTS/client-notes.md`
2. Extract from the free-form text:
   - The business problem to solve
   - The trigger (implicit or explicit)
   - The systems or services mentioned
   - The expected outcome
   - Any constraints or conditions mentioned
3. Use the **`n8n-workflow-patterns`** skill to identify which pattern fits best:
   webhook-process-respond | schedule-fetch-process | event-enrich-route | ai-agent-loop

### Phase 2 — Identify critical ambiguities

Before generating requirements.md, check if any **blocking** information is missing.
If so, ask the user before continuing. Maximum 3–4 questions.

Typical blocking questions:
- **Trigger undefined**: When should this run? External event, schedule, or manual?
- **Ambiguous integration**: They mention "save to database" — which one? Are credentials already in n8n?
- **Unclear output**: What happens at the end — HTTP response, notification, record in another system?
- **Unknown volume**: How many records per execution? (determines if pagination or batch processing is needed)

Do not ask about secondary aspects that can be assumed with technical judgment.
If the user answers "I don't know", propose a sensible default and document it as an assumption.

### Phase 3 — Generate requirements.md

With complete information, generate `changes/$ARGUMENTS/requirements.md`:

```markdown
# Requirements: {WF-ID} — {Descriptive workflow name}

> Generated from client-notes.md via /capture-requirements.
> Source: {input type — email / meeting / etc.} · {date}

## Problem Statement

{Clear description of the business problem, 2–3 sentences.}

## Trigger

- Type: webhook | schedule | manual | event
- Configuration: {URL path / cron expression / event name}
- Origin: {system or person that fires it}

## Input Data

{Description of the data arriving at the trigger.}

Required fields:
- `field`: {description and type}

Example:
{expected payload JSON, inferred or confirmed}

## Expected Output / Side Effects

{What the workflow must produce or do when it completes.}

- {effect 1}
- {effect 2}

## External Integrations

| Service | Purpose | Auth |
|---------|---------|------|
| {name} | {what for} | {API key / OAuth / Basic} |

## Error Scenarios

| Scenario | Expected behavior |
|----------|-----------------|
| External service unavailable | Notify via {channel} and retry |
| Invalid input data | {response / log / discard} |
| Auth failure | Alert {who} |

## Assumptions

{Technical decisions made by default, derived from the conversation or
technical judgment. Mark clearly so the client can validate.}

- Assuming {X} because {reason}. Confirm with client.

## Acceptance Criteria

- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] {criterion 3}

## Out of Scope

- {what this workflow explicitly does NOT do}

## Technical Notes [enriched]

{Technical aspects the client did not mention but are needed to build the workflow:}

- Recommended architectural pattern: {webhook-process-respond /
  schedule-fetch-process / event-enrich-route / ai-agent-loop}
- Idempotency considerations: {yes/no and why}
- Estimated node count: {N nodes approx.}
- Identified technical risks: {list}
```

### Phase 4 — Confirm and save

4. Show the generated `requirements.md` to the user before saving
5. Ask: "Anything to correct or add before saving?"
6. Apply any corrections
7. Save to `changes/$ARGUMENTS/requirements.md`
8. Report: "Done. Next step: `/plan-workflow $ARGUMENTS`
   or `/create-ticket $ARGUMENTS` if you want to create the ticket first."

## Notes

- This command replaces the "fill in the template + `/enrich-workflow-spec`" flow
  for the freelance use case where the developer talks directly to the client
- `/enrich-workflow-spec` remains useful when requirements are written by a PO
  or a non-technical person directly in the file
