---
name: transcribe-audio
description: Transcribe audio using Groq's Whisper-based speech-to-text API
disable-model-invocation: false
allowed-tools: Bash(curl *)
---

# Audio Transcription with Groq

> Fast, accurate speech-to-text transcription powered by Groq's Whisper API

## Prerequisites

- `GROQ_API_KEY` environment variable must be set (provided automatically when connected in Settings)
- `GROQ_TRANSCRIPTION_MODEL` environment variable is set to `whisper-large-v3-turbo` by default

## API Basics

- Base URL: `https://api.groq.com/openai/v1`
- Auth: Bearer token
- Max file size: 25MB
- Supported formats: MP3, MP4, MPEG, MPGA, M4A, WAV, WebM, OGG, FLAC

## Quick Start

### Transcribe a Local Audio File

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL"
```

### Transcribe from URL (Download First)

```bash
# Download the audio file first
curl -L -o /tmp/audio.mp4 "https://example.com/audio.mp4"

# Then transcribe
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/tmp/audio.mp4" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL"
```

## Response Formats

### Basic Response (Default)

```json
{
  "text": "The transcribed text content goes here..."
}
```

### Verbose JSON (With Timestamps)

Add `response_format=verbose_json` for detailed output:

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=verbose_json"
```

Response:

```json
{
  "task": "transcribe",
  "language": "english",
  "duration": 45.67,
  "text": "Full transcription text...",
  "segments": [
    {
      "id": 0,
      "start": 0.0,
      "end": 3.5,
      "text": "First segment text"
    },
    {
      "id": 1,
      "start": 3.5,
      "end": 7.2,
      "text": "Second segment text"
    }
  ]
}
```

## Timestamp Options

### Segment-Level Timestamps

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=segment"
```

### Word-Level Timestamps

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=word"
```

Word-level response includes:

```json
{
  "words": [
    {"word": "Hello", "start": 0.0, "end": 0.3},
    {"word": "world", "start": 0.35, "end": 0.7}
  ]
}
```

### Both Segment and Word Timestamps

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=segment" \
  -F "timestamp_granularities[]=word"
```

## Language Options

### Specify Input Language

Improve accuracy by specifying the language (ISO-639-1 code):

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "language=en"
```

Common language codes: `en`, `es`, `fr`, `de`, `it`, `pt`, `ja`, `ko`, `zh`

## Instagram Reels Workflow

Combine with Apify to transcribe Instagram Reels:

### Step 1: Get Reel Video URL with Apify

```bash
REEL_DATA=$(curl -s -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "directUrls": ["https://www.instagram.com/reel/ABC123/"],
    "resultsLimit": 1
  }')

VIDEO_URL=$(echo "$REEL_DATA" | jq -r '.[0].videoUrl')
```

### Step 2: Download and Transcribe

```bash
# Download the video
curl -L -o /tmp/reel.mp4 "$VIDEO_URL"

# Transcribe
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/tmp/reel.mp4" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=verbose_json"
```

## Available Models

| Model | Description |
|-------|-------------|
| `whisper-large-v3-turbo` | Fast, recommended for most use cases |
| `whisper-large-v3` | Most accurate, slightly slower |
| `distil-whisper-large-v3-en` | English-only, fastest |

## Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `file` | file | Audio file to transcribe (required) |
| `model` | string | Model to use (required) |
| `language` | string | ISO-639-1 language code |
| `prompt` | string | Optional context to improve transcription |
| `response_format` | string | `json`, `text`, `srt`, `verbose_json`, `vtt` |
| `temperature` | float | Sampling temperature (0-1) |
| `timestamp_granularities[]` | array | `segment` and/or `word` |

## Response Formats

| Format | Description |
|--------|-------------|
| `json` | Simple JSON with text field |
| `text` | Plain text only |
| `verbose_json` | Full JSON with segments, timing, language |
| `srt` | SubRip subtitle format |
| `vtt` | WebVTT subtitle format |

### SRT Output Example

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL" \
  -F "response_format=srt"
```

Output:

```
1
00:00:00,000 --> 00:00:03,500
First subtitle text

2
00:00:03,500 --> 00:00:07,200
Second subtitle text
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GROQ_API_KEY` | Groq API key for authentication |
| `GROQ_TRANSCRIPTION_MODEL` | Default model (whisper-large-v3-turbo) |

## Error Handling

| Status | Description |
|--------|-------------|
| `400 Bad Request` | Invalid file format or missing parameters |
| `401 Unauthorized` | Invalid API key |
| `413 Payload Too Large` | File exceeds 25MB limit |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Server error, retry |

## Best Practices

1. **File size** - Keep files under 25MB; split longer audio
2. **Format** - MP3/MP4 work well; convert unusual formats first
3. **Language hint** - Specify language for better accuracy
4. **Use verbose_json** - Get timestamps for subtitles/analysis
5. **Clean up** - Remove temporary files after transcription
6. **Error handling** - Implement retry logic for transient errors

## Translation

To translate audio to English:

```bash
curl -X POST "https://api.groq.com/openai/v1/audio/translations" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@spanish_audio.mp3" \
  -F "model=$GROQ_TRANSCRIPTION_MODEL"
```

Note: Translation always outputs English text.
