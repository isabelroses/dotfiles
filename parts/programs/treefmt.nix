{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {pkgs, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        alejandra.enable = true;
        deadnix.enable = false;
        shellcheck.enable = true;

        prettier = {
          enable = true;
          package = pkgs.prettierd;
          excludes = [];
          settings = {
            editorconfig = true;
          };
        };

        shfmt = {
          enable = true;
          # https://flake.parts/options/treefmt-nix.html#opt-perSystem.treefmt.programs.shfmt.indent_size
          # 0 causes shfmt to use tabs
          indent_size = 2;
        };
      };
    };
  };
}
