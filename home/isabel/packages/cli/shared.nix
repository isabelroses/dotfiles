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
        nix-output-monitor # much nicer nix build output
      ]
      ++ optionals cfg.cli.modernShell.enable [
        vhs # programmatically make gifs
        glow # markdown preview
      ]
      ++ optionals stdenv.isLinux [
        cached-nix-shell
      ];
  };
}
