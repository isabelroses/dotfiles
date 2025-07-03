{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkPackageOption
    mkOption
    ;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.programs.discord;

  settingsFormat = pkgs.formats.json { };
in
{
  options.programs.discord = {
    enable = mkEnableOption "discord support";
    package = mkPackageOption pkgs "discord" { };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = "Settings for Discord";
    };

    moonlight = {
      enable = mkEnableOption "Moonlight support for Discord";

      settings = mkOption {
        inherit (settingsFormat) type;
        default = { };
        description = "Settings for Moonlight";
      };
    };

    vencord = {
      enable = mkEnableOption "Vencord support for Discord";

      settings = mkOption {
        inherit (settingsFormat) type;
        default = { };
        description = "Path to Vencord settings file";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf isLinux {
      garden.packages = {
        discord = cfg.package.override {
          withMoonlight = cfg.moonlight.enable;
          withVencord = cfg.vencord.enable;
        };
      };

      xdg.configFile = {
        "discord/settings.json".source = settingsFormat.generate "discord-settings.json" cfg.settings;
      };
    })

    (mkIf isDarwin {
      home.file = {
        "Library/Application Support/discord/settings.json".source =
          settingsFormat.generate "discord-settings.json" cfg.settings;
      };
    })

    (mkIf (isLinux && cfg.moonlight.enable) {
      xdg.configFile = {
        "moonlight-mod/stable.json".source =
          settingsFormat.generate "moonlight-settings.json" cfg.moonlight.settings;
      };
    })

    (mkIf (isDarwin && cfg.moonlight.enable) {
      home.file = {
        "Library/Application Support/moonlight-mod/stable.json".source =
          settingsFormat.generate "moonlight-settings.json" cfg.moonlight.settings;
      };
    })

    (mkIf (isLinux && cfg.vencord.enable) {
      xdg.configFile = {
        "Vencord/settings/settings.json".source =
          settingsFormat.generate "vencord-settings.json" cfg.vencord.settings;
      };
    })

    (mkIf (isDarwin && cfg.vencord.enable) {
      home.file = {
        "Library/Application Support/Vencord/settings/settings.json".source =
          settingsFormat "vencord-settings.json" cfg.vencord.settings;
      };
    })
  ]);
}
