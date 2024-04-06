{
  lib,
  pkgs,
  osConfig,
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
        just # cool build tool
        dconf
        wakatime
      ]
      ++ optionals cfg.cli.modernShell.enable [
        ripgrep # much better and faster grep
        vhs # programatically make gifs
        glow # markdown preview
      ]
      ++ optionals stdenv.isLinux [
        cached-nix-shell
      ];
  };
}
