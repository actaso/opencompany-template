#!/bin/bash
# Transcribe Instagram Reel audio using Apify + Groq
# Usage: ./transcribe_instagram.sh <reel_url>

set -e

REEL_URL="${1}"

if [ -z "$REEL_URL" ]; then
  echo "Usage: $0 <instagram_reel_url>"
  echo "Example: $0 https://www.instagram.com/reel/ABC123/"
  exit 1
fi

if [ -z "$APIFY_API_TOKEN" ]; then
  echo "Error: APIFY_API_TOKEN environment variable is not set"
  exit 1
fi

if [ -z "$GROQ_API_KEY" ]; then
  echo "Error: GROQ_API_KEY environment variable is not set"
  exit 1
fi

MODEL="${GROQ_TRANSCRIPTION_MODEL:-whisper-large-v3-turbo}"

echo "Fetching reel data from Apify..."
REEL_DATA=$(curl -s -X POST "https://api.apify.com/v2/acts/apify~instagram-reel-scraper/run-sync-get-dataset-items?token=$APIFY_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"directUrls\": [\"$REEL_URL\"],
    \"resultsLimit\": 1
  }")

VIDEO_URL=$(echo "$REEL_DATA" | jq -r '.[0].videoUrl')
CAPTION=$(echo "$REEL_DATA" | jq -r '.[0].caption // "No caption"')
OWNER=$(echo "$REEL_DATA" | jq -r '.[0].ownerUsername // "Unknown"')

if [ -z "$VIDEO_URL" ] || [ "$VIDEO_URL" == "null" ]; then
  echo "Error: Could not get video URL from Apify"
  echo "Response: $REEL_DATA"
  exit 1
fi

echo "Reel by: @$OWNER"
echo "Caption: ${CAPTION:0:100}..."
echo ""
echo "Downloading video..."

TEMP_FILE="/tmp/reel_$(date +%s).mp4"
curl -sL -o "$TEMP_FILE" "$VIDEO_URL"

echo "Transcribing with Groq ($MODEL)..."
TRANSCRIPT=$(curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@$TEMP_FILE" \
  -F "model=$MODEL" \
  -F "response_format=verbose_json")

# Clean up temp file
rm -f "$TEMP_FILE"

# Output results
echo ""
echo "=== Transcription ==="
echo "$TRANSCRIPT" | jq -r '.text // "Transcription failed"'
echo ""
echo "=== Duration ==="
echo "$TRANSCRIPT" | jq -r '.duration // "Unknown"' | xargs -I{} echo "{} seconds"
echo ""
echo "=== Segments ==="
echo "$TRANSCRIPT" | jq -r '.segments[]? | "\(.start)s - \(.end)s: \(.text)"'
