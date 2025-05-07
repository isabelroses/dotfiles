{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  mkLink = config.lib.file.mkOutOfStoreSymlink;
  vencordSettings = "${flakePath}/home/${username}/packages/gui/discord/vencord.json";

  inherit (osConfig.garden.environment) flakePath;
  inherit (config.home) username;

  importToJSON = file: builtins.toJSON (import file);

  settings = importToJSON ./settings.nix;
  moonlightSettings = importToJSON ./moonlight.nix;

  cfg = config.garden.programs.discord;
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      garden.programs.discord = {
        withMoonlight = true;
      };
    }

    (mkIf isLinux {
      home.packages = [ cfg.package ];

      xdg.configFile = {
        "discord/settings.json".text = settings;
      };
    })

    # (mkIf isDarwin {
    #   home.file = {
    #     "Library/Application Support/discord/settings.json".source = settings;
    #   };
    # })

    (mkIf (isLinux && cfg.withMoonlight) {
      xdg.configFile = {
        "moonlight-mod/stable.json".text = moonlightSettings;
      };
    })

    (mkIf (isDarwin && cfg.withMoonlight) {
      home.file = {
        "Library/Application Support/moonlight-mod/stable.json".text = moonlightSettings;
      };
    })

    (mkIf (isLinux && cfg.withVencord) {
      xdg.configFile = {
        "Vencord/settings/settings.json".source = mkLink vencordSettings;
      };
    })

    (mkIf (isDarwin && cfg.withVencord) {
      home.file = {
        "Library/Application Support/Vencord/settings/settings.json".source = mkLink vencordSettings;
      };
    })
  ]);
}
