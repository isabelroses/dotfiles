#!/usr/bin/env nix-shell
#!nix-shell -i bash -p rizin

# from: https://github.com/NixOS/nixpkgs/issues/195512#issuecomment-1546794291

set -e

rizin_cmd="rizin"
rz_find_cmd="rz-find"

discord_version="0.0.28"
file="${HOME}/.config/discord/${discord_version}/modules/discord_krisp/discord_krisp.node"

addr=$($rz_find_cmd -x '4889dfe8........4889dfe8' "${file}" | head -n1)
$rizin_cmd -q -w -c "s $addr + 0x12 ; wao nop" "${file}"
