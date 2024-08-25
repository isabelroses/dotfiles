{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      # don't format these
      excludes = [
        "flake.lock"
        "r'.+\.age$'"
        "r'.+\.patch$'"
      ];

      mkHook =
        name: prev:
        lib.attrsets.recursiveUpdate {
          inherit excludes;
          enable = true;
          description = "pre commit hook for ${name}";
          fail_fast = true;
          verbose = true;
        } prev;

      mkHook' = name: mkHook name { };
    in
    {
      pre-commit = {
        check.enable = true;

        settings = {
          inherit excludes;

          hooks = {
            # make sure our nix code is of good quality before we commit
            statix = mkHook' "statix";
            deadnix = mkHook' "deadnix";

            actionlint = mkHook "actionlint" {
              files = "^.github/workflows/";
            };

            # ensure we have nice formatting
            nixfmt = mkHook "nixfmt" {
              package = pkgs.nixfmt-rfc-style;
            };
            prettier = mkHook "prettier" {
              settings.write = true;
            };
            treefmt = mkHook "treefmt" {
              package = config.treefmt.build.wrapper;
            };
            stylua = mkHook "stylua";
            editorconfig-checker = mkHook "editorconfig" {
              enable = lib.mkForce false;
              always_run = true;
            };

            # check for dead links
            lychee = mkHook "lychee" {
              excludes = [ "^(?!.*\.md$).*" ];
            };

            # make sure there are no typos in the code
            typos = mkHook "typos" {
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
