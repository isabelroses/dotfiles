{ lib, inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    let
      # don't format these
      excludes = [
        "flake.lock"
        "r'.+\.age$'"
        "r'.+\.patch$'"
      ];

      mkHook = name: {
        inherit excludes;
        enable = true;
        description = "pre commit hook for ${name}";
        fail_fast = true;
        verbose = true;
      };

      mkHook' = name: prev: (mkHook name) // prev;
    in
    {
      pre-commit = {
        check.enable = true;

        settings = {
          inherit excludes;

          hooks = {
            # make sure our nix code is of good quality before we commit
            nil = mkHook "nil";
            statix = mkHook "statix";
            deadnix = mkHook "deadnix";

            actionlint = mkHook "actionlint";
            # commitizen = mkHook "commitizen";

            # ensure we have nice formatting
            prettier = mkHook' "prettier" { settings.write = true; };
            treefmt = mkHook' "treefmt" { package = config.treefmt.build.wrapper; };
            stylua = mkHook "stylua";
            editorconfig-checker = mkHook' "editorconfig" {
              enable = lib.mkForce false;
              always_run = true;
            };
            nixfmt = mkHook "nixfmt" // {
              package = pkgs.nixfmt-rfc-style;
            };

            # check for dead links
            lychee = mkHook "lychee";

            # make sure there are no typos in the code
            typos = mkHook' "typos" {
              settings = {
                write = true;
                configuration = ''
                  [default.extend-words]
                  "ags" = "ags"
                  "GIR" = "GIR"
                  "flate" = "flate"
                  "fo" = "fo"
                  "iterm" = "iterm"
                '';
              };
            };
          };
        };
      };
    };
}
