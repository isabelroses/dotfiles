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
            nixfmt = mkHook "nixfmt" // {
              package = pkgs.nixfmt-rfc-style;
            };
            actionlint = mkHook "actionlint";
            # commitizen = mkHook "commitizen";
            # nil = mkHook "nil";

            prettier = mkHook' "prettier" { settings.write = true; };

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

            editorconfig-checker = mkHook' "editorconfig" {
              enable = lib.mkForce false;
              always_run = true;
            };

            treefmt = mkHook' "treefmt" { package = config.treefmt.build.wrapper; };
          };
        };
      };
    };
}
