{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    {
      lib,
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
        prev:
        lib.attrsets.recursiveUpdate {
          inherit excludes;
          enable = true;
          fail_fast = true;
          verbose = true;
        } prev;
    in
    {
      pre-commit = {
        check.enable = true;

        settings = {
          inherit excludes;

          hooks = {
            # make sure our nix code is of good quality before we commit
            statix = mkHook { };
            deadnix = mkHook { };

            actionlint = mkHook {
              files = "^.github/workflows/";
            };

            # ensure we have nice formatting
            nixfmt-rfc-style = mkHook { };
            prettier = mkHook {
              settings.write = true;
            };
            treefmt = mkHook {
              package = config.treefmt.build.wrapper;
            };
            stylua = mkHook { };
            editorconfig-checker = mkHook {
              enable = lib.modules.mkForce false;
              always_run = true;
            };

            # check for dead links
            # lychee = mkHook {
            #   excludes = [ "^(?!.*\.md$).*" ];
            # };

            # make sure there are no typos in the code
            typos = mkHook {
              settings = {
                write = true;
                configuration = ''
                  [files]
                  extend-exclude = [ "**/*.patch" ]

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
