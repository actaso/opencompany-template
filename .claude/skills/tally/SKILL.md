---
name: tally
description: Read form submissions and form data from Tally.so. Use when accessing form responses, listing forms, or analyzing submission data.
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# Tally.so Form Integration

> Access forms, submissions, and form data from your Tally.so workspace

## Prerequisites

- `TALLY_API_KEY` environment variable must be set (provided automatically when connected in Settings)
- `TALLY_WORKSPACE_NAME` environment variable may be set for reference

## API Basics

- Base URL: `https://api.tally.so`
- Auth: Bearer token
- Rate limit: 100 requests/minute

## Forms API

### List All Forms

```bash
curl "https://api.tally.so/forms" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

### Get Form Details

```bash
curl "https://api.tally.so/forms/{formId}" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

### Get Form Questions

```bash
curl "https://api.tally.so/forms/{formId}/questions" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

## Submissions API

### List Form Submissions

```bash
curl "https://api.tally.so/forms/{formId}/submissions" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

### Get Submissions with Pagination

```bash
curl "https://api.tally.so/forms/{formId}/submissions?page=1&limit=50" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

### Get Single Submission

```bash
curl "https://api.tally.so/forms/{formId}/submissions/{submissionId}" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

### Filter Submissions by Date

```bash
curl "https://api.tally.so/forms/{formId}/submissions?afterDate=2024-01-01T00:00:00Z" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

## User & Workspace API

### Get Current User Info

```bash
curl "https://api.tally.so/users/me" \
  -H "Authorization: Bearer $TALLY_API_KEY" \
  -H "Content-Type: application/json"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TALLY_API_KEY` | Tally API Key |
| `TALLY_WORKSPACE_NAME` | Display name of the workspace (optional) |

## Response Format

### Form Object

```json
{
  "id": "form_abc123",
  "name": "Customer Feedback",
  "status": "published",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-02-01T14:20:00Z"
}
```

### Submission Object

```json
{
  "id": "sub_xyz789",
  "formId": "form_abc123",
  "createdAt": "2024-02-10T09:15:00Z",
  "fields": [
    {
      "key": "question_1",
      "label": "Your Name",
      "type": "INPUT_TEXT",
      "value": "John Doe"
    },
    {
      "key": "question_2",
      "label": "Email",
      "type": "INPUT_EMAIL",
      "value": "john@example.com"
    }
  ]
}
```

## Common Use Cases

### Export All Submissions for a Form

```bash
# First, get the form ID by listing forms
curl "https://api.tally.so/forms" \
  -H "Authorization: Bearer $TALLY_API_KEY"

# Then fetch all submissions
curl "https://api.tally.so/forms/{formId}/submissions?limit=100" \
  -H "Authorization: Bearer $TALLY_API_KEY"
```

### Find Forms by Name

```bash
# List all forms and filter by name
curl "https://api.tally.so/forms" \
  -H "Authorization: Bearer $TALLY_API_KEY" | jq '.[] | select(.name | contains("Feedback"))'
```

### Get Recent Submissions

```bash
# Get submissions from the last 7 days
curl "https://api.tally.so/forms/{formId}/submissions?afterDate=$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" \
  -H "Authorization: Bearer $TALLY_API_KEY"
```

### Count Submissions

```bash
# Get submission count for a form
curl "https://api.tally.so/forms/{formId}/submissions" \
  -H "Authorization: Bearer $TALLY_API_KEY" | jq 'length'
```

## Field Types

Common Tally field types you'll encounter:

| Type | Description |
|------|-------------|
| `INPUT_TEXT` | Single-line text input |
| `TEXTAREA` | Multi-line text input |
| `INPUT_EMAIL` | Email address |
| `INPUT_NUMBER` | Numeric input |
| `INPUT_PHONE` | Phone number |
| `INPUT_DATE` | Date picker |
| `INPUT_TIME` | Time picker |
| `MULTIPLE_CHOICE` | Radio button selection |
| `CHECKBOXES` | Multiple checkbox selection |
| `DROPDOWN` | Dropdown menu |
| `LINEAR_SCALE` | Rating scale |
| `FILE_UPLOAD` | File attachment |
| `SIGNATURE` | Signature field |

## Best Practices

- **Use pagination** - For forms with many submissions, use `page` and `limit` parameters
- **Filter by date** - Use `afterDate` parameter to fetch only recent submissions
- **Cache form metadata** - Form structure doesn't change often, cache question IDs and labels
- **Handle rate limits** - Stay under 100 requests/minute, implement backoff if needed

## Error Handling

Common error responses:

| Status | Description |
|--------|-------------|
| `401 Unauthorized` | Invalid or expired API key |
| `403 Forbidden` | API key doesn't have access to this resource |
| `404 Not Found` | Form or submission not found |
| `429 Too Many Requests` | Rate limit exceeded, wait and retry |
| `500 Internal Server Error` | Tally server error, retry later |

Example error response:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid API key"
  }
}
```
