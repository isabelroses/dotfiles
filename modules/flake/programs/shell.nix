{
  perSystem =
    {
      lib,
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

          shellHook = config.pre-commit.installationScript;

          DIRENV_LOG_FORMAT = "";

          FLAKE = ".";
          NH_FLAKE = ".";

          packages =
            [
              pkgs.git # flakes require git
              pkgs.just # quick and easy task runner
              pkgs.cocogitto # git helpers
              self'.formatter # nix formatter
              pkgs.nix-output-monitor # get clean diff between generations
              inputs'.agenix.packages.agenix # secrets
            ]
            ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
              inputs'.deploy-rs.packages.deploy-rs # remote deployment
            ];

          inputsFrom = [ config.treefmt.build.devShell ];
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
