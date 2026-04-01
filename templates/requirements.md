# Requirements: {WF-ID} — {Workflow Name}

> Copy this file to `changes/{WF-ID}/requirements.md` and fill it in.
> Run `/enrich-workflow-spec {WF-ID}` once complete.

## Problem Statement

What business problem does this workflow solve?

## Trigger

How does this workflow start?

- [ ] Webhook (HTTP request from external system)
- [ ] Schedule (cron / interval)
- [ ] Manual (triggered by a user)
- [ ] Event (n8n internal event or workflow trigger)

Trigger details: _(URL path, cron expression, event name, etc.)_

## Input Data

What data arrives at the trigger?

```json
{
  "example": "paste a real or realistic example payload here"
}
```

Required fields: _(list which fields must be present)_

## Expected Output / Side Effects

What must this workflow produce or do?

- [ ] HTTP response (status code, body)
- [ ] Record created/updated in: ___
- [ ] Notification sent to: ___
- [ ] File created/modified: ___
- [ ] Another workflow triggered: ___
- [ ] Other: ___

## External Integrations

Which external services does this workflow need?

| Service | Purpose | Auth method |
|---------|---------|-------------|
| | | |

## Error Scenarios

What should happen when things go wrong?

| Scenario | Expected behavior |
|----------|-----------------|
| External service unavailable | |
| Invalid input data | |
| Auth failure | |

## Acceptance Criteria

This workflow is done when:

- [ ]
- [ ]
- [ ]

## Out of Scope

What this workflow explicitly does NOT do:

-
