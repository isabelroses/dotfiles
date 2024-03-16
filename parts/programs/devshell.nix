{
  perSystem = {
    lib,
    pkgs,
    self',
    config,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "dotfiles";
      meta.description = "Devlopment shell for this configuration";

      shellHook = config.pre-commit.installationScript;

      # tell direnv to shut up
      DIRENV_LOG_FORMAT = "";

      packages = with pkgs;
        [
          git # flakes require git
          nil # nix language server
          nodejs # needed ags
          statix # lints and suggestions
          deadnix # clean up unused nix code
          self'.formatter # nix formatter
          config.treefmt.build.wrapper # treewide formatter
          inputs'.agenix.packages.agenix # secrets
          inputs'.deploy-rs.packages.deploy-rs # remote deployment
        ]
        ++ lib.optionals stdenv.isDarwin [inputs'.darwin.packages.darwin-rebuild];

      inputsFrom = [config.treefmt.build.devShell];
    };
  };
}
