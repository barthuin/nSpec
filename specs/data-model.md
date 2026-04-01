# Data Model

Common data structures shared across nSpec workflows.

## Standard Envelope

All inter-workflow data should follow this envelope:

```json
{
  "meta": {
    "workflowId": "string",
    "executionId": "string",
    "timestamp": "ISO8601",
    "source": "string"
  },
  "data": {}
}
```

## Error Object

Standard error structure for error handler nodes:

```json
{
  "error": {
    "message": "string",
    "node": "string",
    "workflowId": "string",
    "executionId": "string",
    "timestamp": "ISO8601"
  }
}
```

## Domain Models

> Add your project-specific data models here as you define integrations.

### Example: Contact
```json
{
  "id": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "source": "string",
  "createdAt": "ISO8601"
}
```
