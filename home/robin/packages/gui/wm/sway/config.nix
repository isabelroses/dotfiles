{ config, ... }:
let
  inherit (config.garden.programs) defaults;
in
{
  wayland.windowManager.sway = {
    config = {
      modifier = "Mod4";
      workspaceAutoBackAndForth = true;
      inherit (defaults) terminal;
      menu = defaults.launcher;
      defaultWorkspace = "workspace number 1";

      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        {
          # launchers
          "${mod}+Return" = "exec ${defaults.terminal}";
          "${mod}+d" = "exec ${defaults.launcher}";
          "${mod}+b" = "exec ${defaults.browser}";
          "${mod}+e" = "exec ${defaults.fileManager}";
          "${mod}+o" = "exec obsidian";

          "${mod}+l" = "exec swaylock";
          "${mod}+t" = "floating toggle";
          "Print" = "grim -g \"$(slurp)\"";
          "${mod}+q" = "kill";
        };

      window = {
        titlebar = false;
        hideEdgeBorders = "none";
        border = 2;
      };

      gaps = {
        smartBorders = "on";
        outer = 5;
        inner = 5;
      };

      startup = [ { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY"; } ];

      input = {
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
        "type:touchpad" = {
          middle_emulation = "enabled";
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      extraConfig = ''
        set $ws1  1:一
        set $ws2  2:二
        set $ws3  3:三
        set $ws4  4:四
        set $ws5  5:五
        set $ws6  6:六
        set $ws7  7:七
        set $ws8  8:八
        set $ws9  9:九
        set $ws10 10:十

        for_window [window_role="PictureInPicture"] floating enable sticky enable
        for_window [class="Pwvucontrol"] floating enable

        corner_radius       5
        smart_corner_radius enable

        blur                enable
        blur_passes         2
        blur_radius         4
      '';
    };
  };
}
