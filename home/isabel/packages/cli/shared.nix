{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf optionals;
  cfg = osConfig.modules.programs;
in
{
  config = mkIf cfg.cli.enable {
    home.packages =
      with pkgs;
      [
        unzip
        rsync
        just # cool build tool
        wakatime-cli
        nix-output-monitor # much nicer nix build output
      ]
      ++ optionals cfg.cli.modernShell.enable [
        jq # json parser
        yq # yaml parser
        vhs # programmatically make gifs
        glow # markdown preview
      ]
      ++ optionals stdenv.isLinux [ cached-nix-shell ];
  };
}
