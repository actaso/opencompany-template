---
name: file-upload
description: Upload files from the workspace to the organization's cloud storage. Use when saving artifacts, reports, exports, or any files that need to persist beyond the session.
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# File Upload

> Upload files from your workspace to persistent cloud storage

## Prerequisites

This skill requires two environment variables that are automatically injected in agent sessions:

- `OPENCOMPANY_UPLOAD_URL` - The upload endpoint URL
- `OPENCOMPANY_UPLOAD_TOKEN` - Bearer token for authentication (expires after 2 hours)

### Check Availability

```bash
if [ -z "$OPENCOMPANY_UPLOAD_URL" ] || [ -z "$OPENCOMPANY_UPLOAD_TOKEN" ]; then
  echo "File upload is not available in this environment"
  exit 1
fi
```

If these variables are missing, file upload is not available in the current session. This typically means you're not running in an agent session with upload capabilities.

## Uploading Files

### Basic Upload

```bash
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@/path/to/file.pdf"
```

### With Custom Filename

Override the filename that will be stored:

```bash
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@/path/to/report.pdf" \
  -F "filename=Q4-Financial-Report.pdf"
```

### With Label

Add a human-readable label for easier identification:

```bash
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@/path/to/analysis.xlsx" \
  -F "filename=sales-analysis.xlsx" \
  -F "label=Sales Analysis Q4 2024"
```

### Associate with Prompt

Link the file to a specific prompt for context:

```bash
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@/path/to/output.json" \
  -F "promptId=abc123"
```

## Form Fields

| Field | Required | Description |
|-------|----------|-------------|
| `file` | Yes | The file binary (use `@filepath` syntax) |
| `filename` | No | Override stored filename (defaults to original) |
| `label` | No | Human-readable description of the file |
| `promptId` | No | Associate file with a specific prompt |

## Response

### Success

```json
{
  "fileId": "abc123xyz",
  "storageId": "kg2abc123..."
}
```

- `fileId` - Unique identifier for the uploaded file record
- `storageId` - Convex storage identifier

### Errors

| Status | Meaning |
|--------|---------|
| 401 | Invalid or expired token - session may need refresh |
| 400 | Missing file or malformed request |
| 413 | File too large |
| 500 | Server error |

## Examples

### Upload a Generated Report

```bash
# Generate a report
python generate_report.py > report.md

# Upload it
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@report.md" \
  -F "label=Weekly Status Report"
```

### Upload an Image

```bash
curl -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@chart.png" \
  -F "filename=revenue-chart.png" \
  -F "label=Revenue Growth Chart"
```

### Upload with Error Handling

```bash
response=$(curl -s -w "\n%{http_code}" -X POST "$OPENCOMPANY_UPLOAD_URL" \
  -H "Authorization: Bearer $OPENCOMPANY_UPLOAD_TOKEN" \
  -F "file=@document.pdf")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
  echo "Upload successful: $body"
else
  echo "Upload failed with status $http_code: $body"
fi
```

## Important Notes

- **Token expiration**: Tokens expire after 2 hours. If uploads fail with 401, the session may need to be refreshed.
- **File retention**: Uploaded files are retained for 7 days.
- **Supported types**: All file types are supported (PDFs, images, documents, code, data files, etc.)
- **Session context**: This feature is only available within agent sessions that have upload capabilities enabled.
