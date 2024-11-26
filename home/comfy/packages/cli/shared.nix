{
  lib,
  pkgs,
  self',
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  cfg = osConfig.garden.programs;
in
{
  config = mkIf cfg.cli.enable {
    home.packages =
      builtins.attrValues {
        inherit (pkgs)
          unzip
          rsync
          just # cool build tool
          wakatime-cli
          nix-output-monitor # much nicer nix build output
          ;

        inherit (self'.packages) scripts;
      }
      ++ optionals cfg.cli.modernShell.enable (
        builtins.attrValues {
          inherit (pkgs)
            jq # json parser
            yq # yaml parser
            glow # markdown preview
            ;
        }
      );
  };
}
