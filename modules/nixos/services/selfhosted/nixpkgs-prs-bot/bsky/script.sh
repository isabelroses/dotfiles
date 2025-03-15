#!/usr/bin/env bash

if ! bsky show-profile >/dev/null 2>&1; then
  echo "Not logged in. Logging in now..."
  bsky login "$BSKY_EMAIL" "$BSKY_PASSWORD"
fi

OUTPUT=$(nixpkgs-prs --yesterday --plain --no-links)

if [[ -z "$OUTPUT" ]]; then
  echo "No merged PRs found."
  exit 0
fi

# Split output into 300-character chunks
CHUNKS=()
while [[ -n "$OUTPUT" ]]; do
  CHUNKS+=("${OUTPUT:0:300}")
  OUTPUT="${OUTPUT:300}"
done

ROOT_POST=$(bsky post "${CHUNKS[0]}")
THREAD_URL=$(echo "$ROOT_POST" | tail -n1)

for ((i = 1; i < ${#CHUNKS[@]}; i++)); do
  THREAD_URL=$(bsky post -r "$THREAD_URL" "${CHUNKS[$i]}" | tail -n1)
done
