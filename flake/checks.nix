{inputs, ...}: {
  imports = [inputs.pre-commit-hooks.flakeModule];

  perSystem = {system, ...}: {
    checks.${system} = {
      pre-commit = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };
    };
  };
}
