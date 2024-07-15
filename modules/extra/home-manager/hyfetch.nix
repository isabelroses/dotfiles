{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.options)
    mkOption
    mkEnableOption
    mkPackageOption
    literalExpression
    ;
  inherit (lib.modules) mkIf;
  inherit (lib.types)
    nullOr
    either
    path
    lines
    ;
  inherit (lib.strings) isStorePath;
  inherit (builtins) isPath;

  cfg = config.programs.hyfetch;

  settingsFormat = pkgs.formats.json { };
in
{
  options.programs.hyfetch = {
    enable = mkEnableOption "hyfetch";

    package = mkPackageOption pkgs "hyfetch" { };

    settings = mkOption {
      default = { };
      inherit (settingsFormat) type;
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/hyfetch.json`.
        See https://github.com/hykilpikonna/hyfetch/blob/master/docs/hyfetch.1 for more help.
      '';
      example = literalExpression ''
        {
            preset = "lesbian";
            mode = "rgb";
            light_dark = "dark";
            lightness = 0.56;
            color_align = {
                mode = "horizontal";
                custom_colors = [];
                fore_back = null;
            };
            backend = "neofetch";
            distro = null;
            pride_month_shown = [];
            pride_month_disable = false;
        };
      '';
    };

    neofetchConfig = mkOption {
      default = { };
      type = nullOr (either path lines);
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/neofetch/config.conf`.
        See https://github.com/dylanaraps/neofetch/blob/master/neofetch.1 for more help/
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "hyfetch.json" = mkIf (cfg.settings != { }) {
        source = settingsFormat.generate "hyfetch.json" cfg.settings;
      };
      "neofetch/config.conf" = mkIf (cfg.neofetchConfig != { }) {
        source =
          if isPath cfg.neofetchConfig || isStorePath cfg.neofetchConfig then
            cfg.neofetchConfig
          else
            pkgs.writeText "neofetch/config.conf" cfg.neofetchConfig;
      };
    };
  };
}
