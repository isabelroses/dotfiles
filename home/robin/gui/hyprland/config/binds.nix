{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.lists) optionals;
  inherit (builtins) toString genList concatLists;

  inherit (config.garden.programs) defaults;

  mod = "SUPER";

  evswitch = pkgs.writeShellApplication {
    name = "ev-switch";
    runtimeInputs = [
      pkgs.just
      pkgs.lutgen
      pkgs.rhash
    ];
    text = ''
      exec ~/wallpapers/ev-switch.sh
    '';
  };
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # launchers
      "${mod}, B, exec, ${defaults.browser}"
      "${mod}, E, exec, ${defaults.fileManager}"
      "${mod}, C, exec, ${defaults.editor}"
      "${mod}, Return, exec, ${defaults.terminal}"
      "${mod}, L, exec, systemctl suspend"
      "${mod}, O, exec, obsidian"

      "${mod} SHIFT, W, exec, haikei r $(dirname $(haikei current))"
      "${mod} CTRL, W, exec, ${lib.getExe evswitch}"

      # window management
      "${mod}, Q, killactive,"
      # "${mod} SHIFT, Q, exit,"
      "${mod}, F, fullscreen,"
      "${mod}, Z, fullscreen, 1" # toggle maximize
      "${mod} SHIFT, F, fullscreenstate, -1 2" # toggle fullscreenstate in client
      "${mod}, Space, togglefloating,"
      "${mod}, D, pseudo," # dwindle
      "${mod}, J, togglesplit," # dwindle

      # grouping
      "${mod}, g, togglegroup"
      "${mod} ALT, tab, changegroupactive"

      "${mod}, Tab, cyclenext,"
      "${mod}, Tab, bringactivetotop,"

      # special workspace stuff
      "${mod}, grave, togglespecialworkspace"
      "${mod}, grave, exec, $notifycmd 'Toggled Special Workspace'"
      "${mod} SHIFT, grave, movetoworkspace, special"

      # screen shot
      ", Print, exec, moonblast copysave full"
      "${mod} SHIFT, S, exec, moonblast copysave area"
      "ALT, Print, exec, moonblast copysave window"

      "${mod} CTRL, right, workspace, r+1"
      "${mod} CTRL, left, workspace, r-1"
      # scroll wheel binds
      "${mod}, mouse_down, workspace, r+1"
      "${mod}, mouse_up, workspace, r-1"

      # global mute
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      # playerctl
      ",XF86AudioPlay, exec, playercontrol toggle"
      ",XF86AudioNext, exec, playercontrol next"
      ",XF86AudioPrev, exec, playercontrol prev"
    ]
    ++ optionals (defaults.bar == "waybar") [
      "ALT, space, exec, pkill rofi || rofi -show drun"
      "${mod} SHIFT, B, exec, pkill --signal SIGUSR2 waybar" # reload waybar
      "${mod}, escape, exec, wlogout"
      "${mod}, period, exec, killall rofi || rofi -show emoji -emoji-format '{emoji}' -modi emoji"
    ]
    ++ optionals (defaults.bar == "ags") [
      "${mod}, D, exec, ags -t launcher"
      "${mod}, escape, exec, ags -t powermenu"
      "${mod} SHIFT, R, exec, systemctl --user restart ags.service"
    ]
    ++ optionals (defaults.bar == "quickshell") [
      "ALT, space, exec, qs ipc call drawers toggle launcher"
      "${mod} SHIFT, B, exec, pkill quickshell || quickshell &disown"
      "${mod}, escape, exec, qs ipc call drawers toggle session"
    ]
    ++ (concatLists (
      genList (
        x:
        let
          ws =
            let
              c = (x + 1) / 10;
            in
            toString (x + 1 - (c * 10));
        in
        [
          "${mod}, ${ws}, workspace, ${toString (x + 1)}"
          "${mod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      ) 10
    ));

    # mouse binds
    bindm = [
      "${mod}, mouse:272, movewindow"
      "${mod}, mouse:273, resizewindow"
    ];

    # hold to repeat action buttons
    binde = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+ -q"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%- -q"
    ];
  };
}
