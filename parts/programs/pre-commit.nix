{inputs, ...}: {
  imports = [inputs.pre-commit-hooks.flakeModule];

  perSystem = {config, ...}: let
    # don't format these
    excludes = ["flake.lock" "r'.+\.age$'"];

    mkHook = name: prev:
      {
        inherit excludes;
        description = "pre-commit hook for ${name}";
        fail_fast = true;
        verbose = true;
      }
      // prev;
  in {
    pre-commit = {
      check.enable = true;

      settings = {
        inherit excludes;

        hooks = {
          alejandra = mkHook "Alejandra" {enable = true;};
          actionlint = mkHook "actionlint" {enable = true;};
          # prettier = mkHook "prettier" {enable = true;};
          commitizen = mkHook "commitizen" {enable = true;};
          # nil = mkHook "nil" {enable = true;};
          editorconfig-checker = mkHook "editorconfig" {
            enable = false;
            always_run = true;
          };
          treefmt.package = config.treefmt.build.wrapper;
        };
      };
    };
  };
}
