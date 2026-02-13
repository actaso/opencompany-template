---
name: apify
description: Run Apify actors for web scraping including Instagram Reels
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# Apify Actor Integration

> Run Apify actors for web scraping, data extraction, and automation

## Prerequisites

- `APIFY_API_TOKEN` environment variable must be set (provided automatically when connected in Settings)
- `APIFY_ACCOUNT_USERNAME` environment variable may be set for reference

## API Basics

- Base URL: `https://api.apify.com/v2`
- Auth: Bearer token or query param `?token=$APIFY_API_TOKEN`
- Rate limit: Varies by plan

## Instagram Reels Scraping

### Quick Start - Scrape Profile Reels (Sync)

Run the Instagram Reel Scraper and get results immediately (for small requests):

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "directUrls": ["https://www.instagram.com/username/"],
    "resultsLimit": 10
  }'
```

### Scrape Specific Reel URLs

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "directUrls": [
      "https://www.instagram.com/reel/ABC123/",
      "https://www.instagram.com/reel/DEF456/"
    ]
  }'
```

### Async Run (For Large Requests)

Start an async run for large scraping jobs:

```bash
# Start the actor run
curl -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/runs?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "directUrls": ["https://www.instagram.com/username/"],
    "resultsLimit": 100
  }'
```

Response contains the run ID:

```json
{
  "data": {
    "id": "RUN_ID_HERE",
    "status": "RUNNING",
    "defaultDatasetId": "DATASET_ID_HERE"
  }
}
```

### Check Run Status

```bash
curl "https://api.apify.com/v2/actor-runs/RUN_ID_HERE?token=$APIFY_API_TOKEN"
```

### Get Dataset Results

Once the run is complete (status: "SUCCEEDED"):

```bash
curl "https://api.apify.com/v2/datasets/DATASET_ID_HERE/items?token=$APIFY_API_TOKEN"
```

## Instagram Reel Scraper Input Options

| Field | Type | Description |
|-------|------|-------------|
| `directUrls` | array | Profile URLs or Reel URLs to scrape |
| `resultsLimit` | number | Max reels to return (default: 10) |
| `searchType` | string | "hashtag", "user", or "place" |
| `search` | string | Search term when using searchType |

### Example: Scrape by Hashtag

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "searchType": "hashtag",
    "search": "travel",
    "resultsLimit": 20
  }'
```

## Response Format

Each reel in the response contains:

```json
{
  "id": "reel_id",
  "shortCode": "ABC123",
  "url": "https://www.instagram.com/reel/ABC123/",
  "caption": "Reel caption text",
  "commentsCount": 42,
  "likesCount": 1234,
  "videoPlayCount": 5678,
  "videoDuration": 15.5,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "ownerUsername": "username",
  "ownerId": "12345678",
  "videoUrl": "https://...",
  "thumbnailUrl": "https://..."
}
```

## Other Useful Actors

### Instagram Profile Scraper

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~instagram-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "directUrls": ["https://www.instagram.com/username/"],
    "resultsType": "details"
  }'
```

### Web Scraper (Generic)

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~web-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "startUrls": [{"url": "https://example.com"}],
    "pageFunction": "async function pageFunction(context) { return { title: document.title }; }"
  }'
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `APIFY_API_TOKEN` | Apify API token for authentication |
| `APIFY_ACCOUNT_USERNAME` | Account username (informational) |

## Pagination

For large datasets, use `offset` and `limit`:

```bash
curl "https://api.apify.com/v2/datasets/DATASET_ID/items?token=$APIFY_API_TOKEN&offset=0&limit=100"
```

## Cost Considerations

- **Sync runs** (`run-sync-get-dataset-items`): Best for small requests, times out after 5 minutes
- **Async runs**: Required for large scraping jobs
- **resultsLimit**: Always set this to avoid unexpected costs
- **Platform credits**: Each actor run consumes credits based on compute time

## Error Handling

Common errors:

| Status | Description |
|--------|-------------|
| `401 Unauthorized` | Invalid or expired API token |
| `402 Payment Required` | Insufficient credits |
| `404 Not Found` | Actor or run not found |
| `408 Request Timeout` | Sync run exceeded 5 minute limit |
| `429 Too Many Requests` | Rate limit exceeded |

## Best Practices

1. **Start small** - Use `resultsLimit: 10` to test before large scrapes
2. **Use async for large jobs** - Sync runs timeout after 5 minutes
3. **Monitor runs** - Check status before fetching results
4. **Handle rate limits** - Implement backoff for 429 errors
5. **Clean up** - Delete datasets after processing to save storage

## Actor Store

Find more actors at: https://apify.com/store

Popular actors:
- `apify/instagram-reel-scraper` - Instagram Reels
- `apify/instagram-scraper` - Instagram profiles/posts
- `apify/tiktok-scraper` - TikTok videos
- `apify/youtube-scraper` - YouTube videos
- `apify/google-search-scraper` - Google search results
- `apify/web-scraper` - Generic web scraping
