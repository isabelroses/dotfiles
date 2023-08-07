{
  config,
  osConfig,
  lib,
  ...
}: let
  default = osConfig.modules.programs.default;
in {
  wayland.windowManager.sway = {
    config = rec {
      modifier = "Mod4";
      workspaceAutoBackAndForth = true;
      terminal = lib.getExe config.programs.${default.terminal}.package;
      menu = lib.getExe config.programs.${default.launcher}.package;
      defaultWorkspace = "workspace number 1";

      keybindings = let
        mod = modifier;
      in {
        # launchers
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+d" = "exec ${menu}";
        "${mod}+b" = "exec ${default.browser}";

        "${mod}+l" = "exec swaylock";
        "${mod}+q" = "kill";
      };
    };
  };
}
