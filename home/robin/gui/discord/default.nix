{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkMerge;

  vencordSettings = "${flakePath}/home/${username}/gui/discord/vencord.json";

  inherit (osConfig.garden.environment) flakePath;
  inherit (config.home) username;
in
{
  config = mkIf config.programs.discord.enable (mkMerge [
    {
      programs.discord = {
        moonlight = {
          enable = true;
          settings = import ./moonlight.nix { inherit config; };
        };
        vencord = {
          settings = vencordSettings;
        };
        settings = import ./settings.nix;
      };
    }
  ]);
}
