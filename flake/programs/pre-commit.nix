{inputs, ...}: {
  imports = [inputs.pre-commit-hooks.flakeModule];

  perSystem.pre-commit = {
    check.enable = true;

    settings = {
      excludes = ["flake.lock"];

      hooks = {
        alejandra.enable = true;
        prettier.enable = true;
        editorconfig-checker.enable = true;
      };
    };
  };
}
