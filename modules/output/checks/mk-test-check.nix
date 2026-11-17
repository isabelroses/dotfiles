# modified from
# https://github.com/antifuchs/nix-flake-tests/blob/bbd9216bd0f6495bb961a8eb8392b7ef55c67afb/default.nix
#
# NOTE: `lib.debug.runTests` only runs tests whose names start with `test`
{
  lib,
  deepdiff,
  runCommandLocal,
}:
name: tests:
let
  res = lib.debug.runTests tests;
  formatValue =
    val: if (builtins.isList val || builtins.isAttrs val) then builtins.toJSON val else toString val;

  resultToString =
    {
      name,
      expected,
      result,
    }:
    runCommandLocal "${name}-error"
      {
        __structuredAttrs = true;
        strictDeps = true;
        expected = formatValue expected;
        result = formatValue result;
      }
      ''
        printf '%s' "$expected" > expected.json
        printf '%s' "$result" > result.json
        echo "${name} failed (- expected, + result)" > $out
        printf -- '- %s\n+ %s\n' "$expected" "$result" >> $out
        ${deepdiff}/bin/deep diff expected.json result.json >> $out || true
      '';
in
runCommandLocal "${name}-success"
  {
    __structuredAttrs = true;
    strictDeps = true;
    failures = map resultToString res;
  }
  ''
    if [ ''${#failures[@]} -gt 0 ]; then
      for f in "''${failures[@]}"; do
        cat "$f"
        echo
      done
      exit 1
    fi

    touch $out
  ''
