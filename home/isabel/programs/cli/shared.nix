{
  osConfig,
  lib,
  pkgs,
  inputs',
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
      ]
      ++ lib.optionals (cfg.nur.enable && cfg.nur.bella) [
        nur.repos.bella.bellado
        nur.repos.bella.catppuccinifier-cli
      ]
      ++ optionals cfg.cli.modernShell.enable [
        ripgrep
        inputs'.catppuccin-toolbox.packages.catwalk
      ];
  };
}
