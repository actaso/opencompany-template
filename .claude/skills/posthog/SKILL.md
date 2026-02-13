---
name: posthog
description: Query analytics data, run HogQL queries, and analyze user behavior from PostHog. Use when investigating metrics, user activity, funnel performance, or retention patterns.
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# PostHog Analytics Integration

> Query analytics data and analyze user behavior from your PostHog project

## Prerequisites

- `POSTHOG_API_KEY` environment variable must be set (provided automatically when connected in Settings)
- `POSTHOG_PROJECT_ID` environment variable must be set
- `POSTHOG_API_HOST` environment variable must be set (e.g., `https://app.posthog.com`)

## Debug Variables

Before running queries, verify your environment variables are set:

```bash
# Verify your PostHog environment variables are set
echo "Host: ${POSTHOG_API_HOST:-NOT SET}"
echo "Project: ${POSTHOG_PROJECT_ID:-NOT SET}"
echo "API Key: ${POSTHOG_API_KEY:+SET}"
```

## HogQL Queries

HogQL is PostHog's SQL-like query language. It's the most flexible way to analyze your data.

### Simple Event Count

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT event, count() as count FROM events GROUP BY event ORDER BY count DESC LIMIT 10"
    }
  }'
```

### Events by Day

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT toDate(timestamp) as day, count() as count FROM events WHERE timestamp > now() - INTERVAL 7 DAY GROUP BY day ORDER BY day"
    }
  }'
```

### Page Views by URL

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT properties.$current_url as url, count() as views FROM events WHERE event = '\"'\"'$pageview'\"'\"' AND timestamp > now() - INTERVAL 7 DAY GROUP BY url ORDER BY views DESC LIMIT 20"
    }
  }'
```

### User Activity Analysis

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT distinct_id, count() as event_count, min(timestamp) as first_seen, max(timestamp) as last_seen FROM events WHERE timestamp > now() - INTERVAL 30 DAY GROUP BY distinct_id ORDER BY event_count DESC LIMIT 20"
    }
  }'
```

### Funnel Analysis

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/query/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "kind": "HogQLQuery",
      "query": "SELECT countIf(event = '\"'\"'$pageview'\"'\"') as pageviews, countIf(event = '\"'\"'signup_started'\"'\"') as signups, countIf(event = '\"'\"'signup_completed'\"'\"') as completions FROM events WHERE timestamp > now() - INTERVAL 7 DAY"
    }
  }'
```

## Events API

### List Event Definitions

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/event_definitions/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Query Events with Filters

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/events/?event=%24pageview&limit=10" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Get Event Properties

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/property_definitions/?type=event" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

## Insights API

### List All Insights

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/insights/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Get Specific Insight

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/insights/123/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Create a Trend Insight

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/insights/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Daily Active Users",
    "filters": {
      "insight": "TRENDS",
      "events": [{"id": "$pageview", "math": "dau"}],
      "date_from": "-7d"
    }
  }'
```

### Create a Funnel Insight

```bash
curl -X POST "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/insights/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Signup Funnel",
    "filters": {
      "insight": "FUNNELS",
      "events": [
        {"id": "$pageview", "order": 0},
        {"id": "signup_started", "order": 1},
        {"id": "signup_completed", "order": 2}
      ],
      "date_from": "-30d"
    }
  }'
```

## Dashboards API

### List Dashboards

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/dashboards/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Get Dashboard with Tiles

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/dashboards/123/" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

## Persons API

### Search Persons by Email

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/persons/?search=user@example.com" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Get Person by Distinct ID

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/persons/?distinct_id=user-123" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

### Get Person's Event History

```bash
curl "${POSTHOG_API_HOST}/api/projects/${POSTHOG_PROJECT_ID}/events/?person_id=abc-123&limit=50" \
  -H "Authorization: Bearer ${POSTHOG_API_KEY}"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `POSTHOG_API_KEY` | Personal API Key (phx_...) |
| `POSTHOG_PROJECT_ID` | Project ID |
| `POSTHOG_API_HOST` | API host (https://app.posthog.com or https://eu.posthog.com) |
| `POSTHOG_PROJECT_NAME` | Display name of the project |

## Best Practices

- **Use HogQL for complex queries** - It's the most flexible option for custom analysis
- **Add time filters** - Always include date ranges to avoid scanning too much data
- **Use LIMIT** - Limit results to avoid overwhelming responses
- **Check timestamps** - Events use UTC timestamps
- **Cache insights** - For repeated queries, create and save insights in PostHog

## Common HogQL Patterns

### Filter by Event Property

```sql
SELECT * FROM events
WHERE event = '$pageview'
  AND properties.$current_url LIKE '%/pricing%'
```

### Filter by Person Property

```sql
SELECT * FROM events
WHERE person.properties.email LIKE '%@company.com'
```

### Date Ranges

```sql
-- Last 7 days
WHERE timestamp > now() - INTERVAL 7 DAY

-- Specific date range
WHERE timestamp BETWEEN '2024-01-01' AND '2024-01-31'

-- Today
WHERE toDate(timestamp) = today()
```

### Aggregations

```sql
-- Count unique users
SELECT countDistinct(distinct_id) as unique_users FROM events

-- Average per user
SELECT avg(event_count) FROM (
  SELECT distinct_id, count() as event_count FROM events GROUP BY distinct_id
)
```

## Error Handling

Always check the response for errors:

```json
{
  "type": "validation_error",
  "code": "invalid_input",
  "detail": "Invalid query syntax",
  "attr": "query"
}
```

Common errors:
- `401 Unauthorized` - Invalid or expired API key
- `404 Not Found` - Project or resource doesn't exist
- `validation_error` - Invalid query syntax or parameters
- `rate_limit_exceeded` - Too many requests, wait and retry
