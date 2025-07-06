{
  perSystem =
    {
      pkgs,
      self',
      config,
      inputs',
      ...
    }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          name = "dotfiles";
          meta.description = "Development shell for this configuration";

          DIRENV_LOG_FORMAT = "";

          packages = [
            pkgs.just # quick and easy task runner
            pkgs.cocogitto # git helpers
            pkgs.gitMinimal # we need git
            self'.formatter # nix formatter
            pkgs.nix-output-monitor # get clean diff between generations
            inputs'.agenix.packages.agenix # secrets
          ];

          inputsFrom = [ self'.formatter ];
        };

        nixpkgs = pkgs.mkShellNoCC {
          packages = builtins.attrValues {
            inherit (pkgs)
              # package creation helpers
              nurl
              nix-init

              # nixpkgs dev stuff
              hydra-check
              nixpkgs-lint
              nixpkgs-review
              nixpkgs-hammering

              # nix helpers
              nix-melt
              nix-tree
              nix-inspect
              nix-search-cli
              ;
          };
        };
      };
    };
}
