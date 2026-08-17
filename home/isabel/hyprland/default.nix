{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) toLua;

  inherit (config.garden.programs) defaults;
  inherit (osConfig.garden.device) monitors keyboard;

  monitorList = mapAttrsToList (output: mon: {
    inherit output;
    inherit (mon) position scale;
    mode = "${mon.res}@${toString mon.hz}";
  }) monitors;
in
{
  options.programs.hyprland.enable = lib.options.mkEnableOption "Enable Hyprland as the Wayland window manager";

  config = lib.modules.mkIf config.programs.hyprland.enable {
    garden.packages = { inherit (pkgs) hyprpicker cosmic-files; };

    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;

      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      # I AM NOT WRITING LUA IN NIX
      configType = "lua";
      extraConfig = ''
        local kb = "${keyboard}"
        local terminal = "${defaults.terminal}"
        local screenLocker = "${defaults.screenLocker}"
        local monitors = ${toLua { } monitorList}
        ${builtins.readFile ./config.lua}
      '';
    };
  };
}
