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

          packages = [
            pkgs.git # flakes require git
            pkgs.just # quick and easy task runner
            self'.formatter # nix formatter
            pkgs.nix-output-monitor # get clean diff between generations
            inputs'.agenix.packages.agenix # secrets
            inputs'.deploy-rs.packages.deploy-rs # remote deployment
          ] ++ lib.optionals pkgs.stdenv.isDarwin [ inputs'.darwin.packages.darwin-rebuild ];

          inputsFrom = [ config.treefmt.build.devShell ];
        };

        nixpkgs = pkgs.mkShellNoCC {
          packages = with pkgs; [
            statix
            deadnix
            hydra-check
            nix-inspect
            nix-melt
            nix-prefetch-git
            nix-prefetch-github
            nix-search-cli
            nix-tree
            nixpkgs-hammering
            nixpkgs-lint
            nixpkgs-review
            nix-output-monitor
          ];
        };
      };
    };
}
