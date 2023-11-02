{
  osConfig,
  lib,
  pkgs,
  inputs',
  self',
  ...
}: let
  inherit (lib) mkIf optionals;
  cfg = osConfig.modules.programs;
in {
  config = mkIf cfg.cli.enable {
    home.packages = with pkgs;
      [
        # CLI packages from nixpkgs
        unzip
        rsync
        fd
        jq
        dconf
        nitch
        hyfetch
        cached-nix-shell
        self'.packages.bellado
        self'.packages.catppuccinifier-cli
      ]
      ++ optionals cfg.cli.modernShell.enable [
        ripgrep
      ];
  };
}
