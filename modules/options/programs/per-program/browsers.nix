{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.programs.browsers = {
    chromium = {
      enable = mkEnableOption "Chromium browser";
      ungoogle = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ungoogled-chromium features";
      };
      # TODO: thorium
    };

    firefox = {
      enable = mkEnableOption "Firefox browser";
      schizofox = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Schizofox Firefox Tweaks";
      };
    };
  };
}
