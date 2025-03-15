#!/usr/bin/env bash

if [ -z "${1+x}" ]; then
  set -- ""
fi

# Check for --yesterday flag to fetch PRs from yesterday
if [[ $1 == "--yesterday" ]]; then
  DATE=$(date -u -d "yesterday" +"%Y-%m-%d")
else
  DATE=$(date -u +"%Y-%m-%d")
fi

if [ -z "${2+x}" ]; then
  set -- "$1" ""
fi

if [[ $2 == "--json" ]]; then
  FORMAT="json"
elif [[ $2 == "--plain" ]]; then
  FORMAT="text"
else
  FORMAT="markdown"
fi

if [ -z "${3+x}" ]; then
  set -- "$1" "$2" ""
fi

if [[ $3 == "--no-links" ]]; then
  NO_LINKS="true"
else
  NO_LINKS="false"
fi

REPO="nixos/nixpkgs"

PRs=$(gh pr list --repo $REPO --state merged --search "merged:$DATE" --json title,number,url)

declare -A categories_top
declare -A categories_bottom
categories_top[modules]=""
categories_bottom[modules]=""
categories_top[lib]=""
categories_bottom[lib]=""
categories_top[packages]=""
categories_bottom[packages]=""

while IFS= read -r pr; do
  title=$(echo "$pr" | jq -r '.title')
  number=$(echo "$pr" | jq -r '.number')
  url=$(echo "$pr" | jq -r '.url')

  if [[ $title == *Backport* ]]; then
    continue
  elif [[ $title == nixos* ]]; then
    category="modules"
  elif [[ $title == lib* ]]; then
    category="lib"
  else
    category="packages"
  fi

  if [[ $NO_LINKS == "true" ]]; then
    entry="- #${number} $title"
  else
    entry="- [#${number}](${url}) $title"
  fi

  if [[ $title == *init* ]]; then
    categories_top[$category]+="$entry"$'\n'
  else
    categories_bottom[$category]+="$entry"$'\n'
  fi
done < <(echo "$PRs" | jq -c '.[]')

if [[ $FORMAT == "text" ]]; then
  echo "Merged PRs for $DATE"

  for category in modules lib packages; do
    content="${categories_top[$category]}${categories_bottom[$category]}"
    if [[ -n $content ]]; then
      echo -e "\n${category^}\n$content"
    fi
  done
elif [[ $FORMAT == "markdown" ]]; then
  echo "# Merged PRs for $DATE"

  for category in modules lib packages; do
    content="${categories_top[$category]}${categories_bottom[$category]}"
    if [[ -n $content ]]; then
      echo -e "\n## ${category^}\n$content"
    fi
  done
else
  json_output="{\"date\":\"$DATE\""
  for category in modules lib packages; do
    content="${categories_top[$category]}${categories_bottom[$category]}"
    if [[ -n $content ]]; then
      json_output+=", \"$category\": {\"items\": \"$content\"}"
    fi
  done
  json_output+="}"
  echo "$json_output" | jq .
fi
