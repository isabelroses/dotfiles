#!/usr/bin/env bash
usage() {
  echo "usage: update-pins [chromium|brew|vicinae]..." >&2
  exit 2
}

FLAKE_ROOT="${FLAKE:-$(git rev-parse --show-toplevel)}"

CHROMIUM_FILE="$FLAKE_ROOT/home/isabel/chromium.nix"
BREW_FILE="$FLAKE_ROOT/modules/darwin/brew/default.nix"
VICINAE_EXT_FILE="$FLAKE_ROOT/home/isabel/vicinae/extension.nix"
VICINAE_FILE="$FLAKE_ROOT/home/isabel/vicinae/default.nix"

# shellcheck disable=SC2329
prefetch_github() {
  nurl -H "https://github.com/$1/$2" "$3"
}

# shellcheck disable=SC2329
is_sri() {
  [[ $1 =~ ^sha256-[A-Za-z0-9+/]{43}=$ ]]
}

# shellcheck disable=SC2329
crx_url() {
  echo "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${CHROME_MAJOR}&x=id%3D${1}%26installsource%3Dondemand%26uc"
}

# shellcheck disable=SC2329
update_chromium() {
  local version
  if [ -n "${CHROME_VERSION:-}" ]; then
    version="$CHROME_VERSION"
  else
    version=$(nix eval --raw "$FLAKE_ROOT#nixosConfigurations.$(hostname).config.home-manager.users.isabel.programs.chromium.package.version")
  fi
  CHROME_MAJOR="${version%%.*}"

  local id current location latest hash rc=0 count=0
  while read -r id; do
    count=$((count + 1))
    current=$(sed -n "/id = \"$id\"/,/}/ s/.*version = \"\(.*\)\";.*/\1/p" "$CHROMIUM_FILE") || {
      echo "chromium/$id: failed to read current version" >&2
      rc=1
      continue
    }

    location=$(curl -fsI "$(crx_url "$id")" | tr -d '\r' | sed -n 's/^[Ll]ocation: //p') || {
      echo "chromium/$id: version discovery failed" >&2
      rc=1
      continue
    }

    # CJPAL..._1_72_2_0.crx -> 1.72.2; the store pads versions to four
    # components, so strip one trailing .0 (a real 4-part version ending
    # in .0 would be mis-parsed, none of ours are)
    latest=$(basename "$location" .crx)
    latest=${latest#"${id^^}"_}
    latest=${latest//_/.}
    if [[ $latest == *.*.*.* ]]; then
      latest=${latest%.0}
    fi

    [[ $latest =~ ^[0-9]+(\.[0-9]+)*$ ]] || {
      echo "chromium/$id: unexpected version '$latest'" >&2
      rc=1
      continue
    }

    if [ "$latest" = "$current" ]; then
      echo "chromium/$id: up to date ($current)"
      continue
    fi

    hash=$(nix store prefetch-file --name "$id.crx" --json "$(crx_url "$id")" | jq -r .hash) || {
      echo "chromium/$id: prefetch failed" >&2
      rc=1
      continue
    }
    is_sri "$hash" || {
      echo "chromium/$id: unexpected hash '$hash'" >&2
      rc=1
      continue
    }

    sed -i "/id = \"$id\"/,/}/ {
      s|version = \".*\";|version = \"$latest\";|
      s|hash = \".*\";|hash = \"$hash\";|
    }" "$CHROMIUM_FILE" || {
      echo "chromium/$id: failed to edit $CHROMIUM_FILE" >&2
      rc=1
      continue
    }
    echo "chromium/$id: $current -> $latest"
  done < <(sed -n 's/.*id = "\([a-p]\{32\}\)";.*/\1/p' "$CHROMIUM_FILE")

  if [ "$count" -eq 0 ]; then
    echo "chromium: found no extension ids in $CHROMIUM_FILE" >&2
    return 1
  fi

  return "$rc"
}

# shellcheck disable=SC2329
update_brew() {
  local tag current hash repo rev rc=0

  tag=$(gh api "repos/homebrew/brew/releases/latest" --jq .tag_name) || {
    echo "brew: failed to query the latest release" >&2
    return 1
  }
  [[ $tag =~ ^[0-9A-Za-z._-]+$ ]] || {
    echo "brew: unexpected tag '$tag'" >&2
    return 1
  }
  current=$(sed -n 's/.*tag = "\(.*\)";.*/\1/p' "$BREW_FILE") || {
    echo "brew: failed to read current pin" >&2
    return 1
  }
  if [ "$tag" = "$current" ]; then
    echo "brew: up to date ($tag)"
  else
    hash=$(prefetch_github homebrew brew "$tag") || {
      echo "brew: prefetch failed for tag $tag" >&2
      return 1
    }
    is_sri "$hash" || {
      echo "brew: unexpected hash '$hash'" >&2
      return 1
    }
    sed -i "/repo = \"brew\";/,/}/ {
      s|tag = \".*\";|tag = \"$tag\";|
      s|hash = \".*\";|hash = \"$hash\";|
    }" "$BREW_FILE" || {
      echo "brew: failed to edit $BREW_FILE" >&2
      return 1
    }
    echo "brew: $current -> $tag"
  fi

  for repo in homebrew-core homebrew-cask; do
    rev=$(gh api "repos/homebrew/$repo/commits/HEAD" --jq .sha) || {
      echo "$repo: failed to query HEAD" >&2
      rc=1
      continue
    }
    [[ $rev =~ ^[0-9a-f]{40}$ ]] || {
      echo "$repo: unexpected rev '$rev'" >&2
      rc=1
      continue
    }
    current=$(sed -n "/repo = \"$repo\";/,/}/ s/.*rev = \"\(.*\)\";.*/\1/p" "$BREW_FILE") || {
      echo "$repo: failed to read current pin" >&2
      rc=1
      continue
    }
    if [ "$rev" = "$current" ]; then
      echo "$repo: up to date (${rev:0:12})"
      continue
    fi
    hash=$(prefetch_github homebrew "$repo" "$rev") || {
      echo "$repo: prefetch failed for ${rev:0:12}" >&2
      rc=1
      continue
    }
    is_sri "$hash" || {
      echo "$repo: unexpected hash '$hash'" >&2
      rc=1
      continue
    }
    sed -i "/repo = \"$repo\";/,/}/ {
      s|rev = \".*\";|rev = \"$rev\";|
      s|hash = \".*\";|hash = \"$hash\";|
    }" "$BREW_FILE" || {
      echo "$repo: failed to edit $BREW_FILE" >&2
      rc=1
      continue
    }
    echo "$repo: ${current:0:12} -> ${rev:0:12}"
  done

  return "$rc"
}

# shellcheck disable=SC2329
vicinae_exts() { # -> lines of "<extName> <type>" for each active extension
  gawk '
    /^ *\{/ { name = ""; type = "vicinae" }
    /^ *extName = / { split($0, a, "\""); name = a[2] }
    /^ *type = / { split($0, a, "\""); type = a[2] }
    /^ *\}/ { if (name != "") print name, type; name = "" }
  ' "$VICINAE_FILE"
}

# shellcheck disable=SC2329
raycast_fetch_expr() { # <rev> <extName> <hash> -> nix expr on stdout
  cat <<EOF
let
  flake = builtins.getFlake "$FLAKE_ROOT";
  pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
in
pkgs.fetchFromGitHub {
  owner = "raycast";
  repo = "extensions";
  rev = "$1";
  hash = "$3";
  sparseCheckout = [ "/extensions/$2" ];
}
EOF
}

# shellcheck disable=SC2329
update_raycast() {
  local rev current ext type hash src npm
  local -a raycast_exts=()

  while read -r ext type; do
    if [ "$type" = "raycast" ]; then
      raycast_exts+=("$ext")
    fi
  done < <(vicinae_exts)

  if [ ${#raycast_exts[@]} -eq 0 ]; then
    echo "raycast: no extensions pinned, skipping"
    return 0
  fi
  if [ ${#raycast_exts[@]} -gt 1 ]; then
    echo "raycast: extension.nix shares one hash across all raycast extensions, refusing to update ${#raycast_exts[@]} of them" >&2
    return 1
  fi
  ext="${raycast_exts[0]}"

  rev=$(gh api "repos/raycast/extensions/commits/HEAD" --jq .sha) || {
    echo "raycast: failed to query HEAD" >&2
    return 1
  }
  [[ $rev =~ ^[0-9a-f]{40}$ ]] || {
    echo "raycast: unexpected rev '$rev'" >&2
    return 1
  }
  current=$(sed -n '/owner = "raycast";/,/}/ s/.*rev = "\(.*\)";.*/\1/p' "$VICINAE_EXT_FILE") || {
    echo "raycast: failed to read current pin" >&2
    return 1
  }
  if [ "$rev" = "$current" ]; then
    echo "raycast/extensions: up to date (${rev:0:12})"
    return 0
  fi

  # the sparse checkout makes this a different FOD per extension, which
  # plain prefetchers can't compute; nurl passes the arg through to the
  # fetcher and harvests the hash for us
  hash=$(nurl -H -f fetchFromGitHub -a sparseCheckout "[\"/extensions/$ext\"]" \
    "https://github.com/raycast/extensions" "$rev") || {
    echo "raycast: nurl failed for ${rev:0:12}" >&2
    return 1
  }
  is_sri "$hash" || {
    echo "raycast: unexpected hash '$hash'" >&2
    return 1
  }

  src=$(nix build --impure --no-link --print-out-paths \
    --expr "$(raycast_fetch_expr "$rev" "$ext" "$hash")") || {
    echo "raycast: fetch with the harvested hash failed" >&2
    return 1
  }
  npm=$(prefetch-npm-deps "$src/extensions/$ext/package-lock.json") || {
    echo "raycast/$ext: prefetch-npm-deps failed" >&2
    return 1
  }
  is_sri "$npm" || {
    echo "raycast/$ext: unexpected npm hash '$npm'" >&2
    return 1
  }

  sed -i "/owner = \"raycast\";/,/}/ {
    s|rev = \".*\";|rev = \"$rev\";|
    s|hash = \".*\";|hash = \"$hash\";|
  }" "$VICINAE_EXT_FILE" || {
    echo "raycast: failed to edit $VICINAE_EXT_FILE" >&2
    return 1
  }
  sed -i "/extName = \"$ext\";/,/}/ s|npmDepsHash = \".*\";|npmDepsHash = \"$npm\";|" "$VICINAE_FILE" || {
    echo "raycast: failed to edit $VICINAE_FILE" >&2
    return 1
  }
  echo "raycast/extensions: ${current:0:12} -> ${rev:0:12} ($ext)"
}

# shellcheck disable=SC2329
update_vicinae() {
  local rev current hash src ext type npm rc=0
  local -a npm_exts=() npm_hashes=()

  rev=$(gh api "repos/vicinaehq/extensions/commits/HEAD" --jq .sha) || {
    echo "vicinae: failed to query HEAD" >&2
    return 1
  }
  [[ $rev =~ ^[0-9a-f]{40}$ ]] || {
    echo "vicinae: unexpected rev '$rev'" >&2
    return 1
  }
  current=$(sed -n '/owner = "vicinaehq";/,/}/ s/.*rev = "\(.*\)";.*/\1/p' "$VICINAE_EXT_FILE") || {
    echo "vicinae: failed to read current pin" >&2
    return 1
  }

  if [ "$rev" = "$current" ]; then
    echo "vicinae/extensions: up to date (${rev:0:12})"
  else
    hash=$(prefetch_github vicinaehq extensions "$rev") || {
      echo "vicinae: prefetch failed for ${rev:0:12}" >&2
      return 1
    }
    is_sri "$hash" || {
      echo "vicinae: unexpected hash '$hash'" >&2
      return 1
    }
    src=$(nix flake prefetch --json "github:vicinaehq/extensions/$rev" | jq -r .storePath) || {
      echo "vicinae: failed to fetch the source tree" >&2
      return 1
    }

    # prefetch every npm hash before writing anything, so a mid-loop
    # failure can't leave a bumped rev paired with a stale npmDepsHash
    while read -r ext type; do
      if [ "$type" != "vicinae" ]; then
        continue
      fi
      npm=$(prefetch-npm-deps "$src/extensions/$ext/package-lock.json") || {
        echo "vicinae/$ext: prefetch-npm-deps failed" >&2
        return 1
      }
      is_sri "$npm" || {
        echo "vicinae/$ext: unexpected npm hash '$npm'" >&2
        return 1
      }
      npm_exts+=("$ext")
      npm_hashes+=("$npm")
    done < <(vicinae_exts)

    sed -i "/owner = \"vicinaehq\";/,/}/ {
      s|rev = \".*\";|rev = \"$rev\";|
      s|hash = \".*\";|hash = \"$hash\";|
    }" "$VICINAE_EXT_FILE" || {
      echo "vicinae: failed to edit $VICINAE_EXT_FILE" >&2
      return 1
    }
    echo "vicinae/extensions: ${current:0:12} -> ${rev:0:12}"

    local i
    for i in "${!npm_exts[@]}"; do
      ext="${npm_exts[$i]}"
      npm="${npm_hashes[$i]}"
      sed -i "/extName = \"$ext\";/,/}/ s|npmDepsHash = \".*\";|npmDepsHash = \"$npm\";|" "$VICINAE_FILE" || {
        echo "vicinae/$ext: failed to edit $VICINAE_FILE" >&2
        rc=1
        continue
      }
      echo "vicinae/$ext: npmDepsHash refreshed"
    done
  fi

  update_raycast || rc=1
  return "$rc"
}

failed=0

run_target() {
  if ! "update_$1"; then
    echo "$1: FAILED" >&2
    failed=1
  fi
}

main() {
  local -a targets=("$@")
  if [ ${#targets[@]} -eq 0 ]; then
    targets=(chromium brew vicinae)
  fi

  local t
  for t in "${targets[@]}"; do
    case "$t" in
    chromium | brew | vicinae) run_target "$t" ;;
    *) usage ;;
    esac
  done

  exit "$failed"
}

main "$@"
