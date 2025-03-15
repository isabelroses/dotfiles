#!/usr/bin/env bash

if [[ -z $FEDI_INSTANCE || -z $FEDI_EMAIL || -z $FEDI_PASSWORD ]]; then
  echo "Missing Mastodon credentials. Set FEDI_INSTANCE, FEDI_EMAIL, and FEDI_PASSWORD."
  exit 1
fi

if ! toot auth | grep -q "You are logged in"; then
  echo "Logging in to fedi..."
  toot login_cli -i "$FEDI_INSTANCE" -e "$FEDI_EMAIL" -p "$FEDI_PASSWORD"
fi

OUTPUT=$(nixpkgs-prs --yesterday --plain)

# Ensure output isn't empty
if [[ -z $OUTPUT ]]; then
  echo "No merged PRs found. Exiting."
  exit 0
fi

# Post to Mastodon using toot CLI
toot post -v public -t "text/markdown" "$OUTPUT"
