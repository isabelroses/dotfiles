{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.lists)
    elemAt
    genList
    imap0
    length
    ;
  inherit (lib.strings) optionalString concatLines;
  inherit (lib.trivial) mod min;

  inherit (config.garden.programs) defaults;
  inherit (osConfig.garden.device) monitors keyboard;

  mapMonitors = concatLines (
    imap0 (i: output: ''
      hl.monitor({
        output = "${output}",
        mode = "preferred",
        position = "${toString (i * 1920)}x0",
        scale = "auto",
      })
    '') monitors
  );

  mapMonitorsToWs =
    let
      count = length monitors;
      perMon = 10 / count;
      extra = mod 10 count;
      monitorIdx =
        i: if i < perMon + extra then 0 else min (1 + (i - perMon - extra) / perMon) (count - 1);
      rule = i: ''
        hl.workspace_rule({ workspace = ${toString (i + 1)}, monitor = "${elemAt monitors (monitorIdx i)}"${
          optionalString (i == 0) ", default = true"
        } })
      '';
    in
    concatLines (genList rule 10);
in
{
  options.programs.hyprland.enable = lib.mkEnableOption "Enable Hyprland as the Wayland window manager";

  config = lib.mkIf config.programs.hyprland.enable {
    garden.packages = { inherit (pkgs) hyprpicker cosmic-files; };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;

      package = null;
      portalPackage = null;

      # I AM NOT WRITING LUA IN NIX
      configType = "lua";
      extraConfig = ''
        local kb = "${keyboard}"
        local editor = "${defaults.editor}"
        local terminal = "${defaults.terminal}"
        local screenLocker = "${defaults.screenLocker}"

        ${mapMonitors}
        ${optionalString (length monitors != 1) mapMonitorsToWs}
        ${builtins.readFile ./config.lua}
      '';
    };
  };
}
