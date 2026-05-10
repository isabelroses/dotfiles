{
  lib,
  deepdiff,
  runCommandLocal,
  self,
}:
let
  res = lib.debug.runTests {
    boolToNum = {
      expr = self.lib.helpers.boolToNum true;
      expected = 1;
    };

    intListToStringList = {
      expr = self.lib.helpers.intListToStringList [
        1
        2
        3
      ];
      expected = [
        "1"
        "2"
        "3"
      ];
    };

    indexOf = {
      expr = self.lib.helpers.indexOf [
        1
        2
        3
      ] 2;
      expected = 1;
    };

    containsStrings = {
      expr =
        self.lib.helpers.containsStrings
          [
            "a"
            "b"
            "c"
          ]
          [
            "a"
            "b"
          ];
      expected = true;
    };

    giturl = {
      expr = self.lib.helpers.giturl {
        domain = "github.com";
        alias = "gh";
      };
      expected = {
        "https://github.com/".insteadOf = "gh:";
        "ssh://git@github.com/".pushInsteadOf = "gh:";
      };
    };

    mkPub = {
      expr = self.lib.helpers.mkPub "github.com" {
        type = "rsa";
        key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      };
      expected = {
        "github.com-rsa" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
        };
      };
    };
  };

  # modified from
  # https://github.com/antifuchs/nix-flake-tests/blob/bbd9216bd0f6495bb961a8eb8392b7ef55c67afb/default.nix
  formatValue =
    val: if (builtins.isList val || builtins.isAttrs val) then builtins.toJSON val else toString val;

  resultToString =
    {
      name,
      expected,
      result,
    }:
    runCommandLocal "nix-flake-tests-error"
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
        ${deepdiff}/bin/deep diff expected.json result.json >> $out
      '';
in
runCommandLocal "nix-flake-tests-success"
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
