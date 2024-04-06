{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true;
        deadnix.enable = false;

        shellcheck.enable = true;

        prettier = {
          enable = true;
          package = pkgs.prettierd;
          excludes = ["*.age"];
          settings = {
            editorconfig = true;
          };
        };

        shfmt = {
          enable = true;
          indent_size = 2;
        };
      };
    };
  };
}
