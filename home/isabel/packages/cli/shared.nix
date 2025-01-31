{
  lib,
  pkgs,
  self',
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;
  cfg = config.garden.programs;
in
{
  config = mkIf cfg.cli.enable {
    garden.packages =
      {
        inherit (pkgs)
          unzip
          rsync
          just # cool build tool
          wakatime-cli
          nix-output-monitor # much nicer nix build output
          ;

        inherit (self'.packages) scripts;
      }
      // optionalAttrs cfg.cli.modernShell.enable {
        inherit (pkgs)
          jq # json parser
          yq # yaml parser
          ;
      };
  };
}
