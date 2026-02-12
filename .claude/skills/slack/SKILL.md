---
name: slack
description: Send messages and read channel history in Slack. Use when posting updates, retrieving messages, or interacting with the team workspace.
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# Slack Integration

> Send messages and interact with your team's Slack workspace

## Prerequisites

- `SLACK_BOT_TOKEN` environment variable must be set (provided automatically when connected in Settings)
- Bot must be invited to channels you want to post to

## Sending Messages

### To a Public Channel

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "general",
    "text": "Hello from the agent!"
  }'
```

### To a Channel by ID

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "C01234567",
    "text": "Hello!"
  }'
```

### With Formatting (Blocks)

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "general",
    "blocks": [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Task Complete*\nDeployed version 1.2.3 to production"
        }
      }
    ]
  }'
```

## Reading Messages

### Get Channel History

```bash
curl "https://slack.com/api/conversations.history?channel=C01234567&limit=20" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

### Get Thread Replies

```bash
curl "https://slack.com/api/conversations.replies?channel=C01234567&ts=1234567890.123456" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

## Finding Channels

### List Public Channels

```bash
curl "https://slack.com/api/conversations.list?types=public_channel" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

### List Private Channels (requires groups:read scope)

```bash
curl "https://slack.com/api/conversations.list?types=private_channel" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

## Threading

### Reply in a Thread

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "C01234567",
    "thread_ts": "1234567890.123456",
    "text": "This is a reply in the thread"
  }'
```

## Looking Up Users

```bash
curl "https://slack.com/api/users.list" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SLACK_BOT_TOKEN` | Bot User OAuth Token (xoxb-...) |
| `SLACK_TEAM_ID` | Workspace ID |
| `SLACK_TEAM_NAME` | Workspace name |

## Best Practices

- **Use threads** to avoid channel noise when posting updates
- **Keep messages concise** and actionable
- **Tag users sparingly** - only when they need to take action
- **Use blocks** for structured content like reports or summaries
- **Check channel membership** before posting to private channels

## Required Bot Token Scopes

Minimum scopes for basic functionality:
- `chat:write` - Send messages
- `channels:read` - List public channels
- `channels:history` - Read public channel messages

Optional scopes for extended functionality:
- `groups:read` - List private channels
- `groups:history` - Read private channel messages
- `users:read` - Look up users
- `files:write` - Upload files

## Error Handling

Always check the response for errors:

```json
{
  "ok": false,
  "error": "channel_not_found"
}
```

Common errors:
- `channel_not_found` - Channel doesn't exist or bot isn't a member
- `not_in_channel` - Bot needs to be invited to the channel
- `invalid_auth` - Token is invalid or expired
