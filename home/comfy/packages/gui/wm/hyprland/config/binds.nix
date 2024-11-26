{ lib, defaults, ... }:
let
  inherit (lib.lists) optionals;
  inherit (builtins) toString genList concatLists;

  mod = "SUPER";
in
{
  wayland.windowManager.hyprland.settings = {
    bind =
      [
        # launchers
        "${mod}, B, exec, ${defaults.browser}"
        "${mod}, E, exec, ${defaults.fileManager}"
        "${mod}, C, exec, ${defaults.editor}"
        "${mod}, Return, exec, ${defaults.terminal}"
        "${mod}, L, exec, ${defaults.screenLocker}"
        "${mod}, O, exec, obsidian"

        # window management
        "${mod}, Q, killactive,"
        # "${mod} SHIFT, Q, exit,"
        "${mod}, F, fullscreen,"
        "${mod}, Space, togglefloating,"
        "${mod}, P, pseudo," # dwindle
        "${mod}, S, togglesplit," # dwindle

        # grouping
        "${mod}, g, togglegroup"
        "${mod}, tab, changegroupactive"

        # special workspace stuff
        "${mod}, grave, togglespecialworkspace"
        "${mod} SHIFT, grave, movetoworkspace, special"

        # screen shot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "${mod} SHIFT, s, exec, grim -g \"$(slurp)\" - | wl-copy"

        # scroll wheel binds
        "${mod}, mouse_down, workspace, e+1"
        "${mod}, mouse_up, workspace, e-1"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ]
      ++ optionals (defaults.bar == "waybar") [
        "${mod}, D, exec, rofi -show drun"
        "${mod}, escape, exec, wlogout"
        "${mod}, period, exec, killall rofi || rofi -show emoji -emoji-format '{emoji}' -modi emoji"
      ]
      ++ optionals (defaults.bar == "ags") [
        "${mod}, D, exec, ags -t launcher"
        "${mod}, escape, exec, ags -t powermenu"
        "${mod} SHIFT, R, exec, systemctl --user restart ags.service"
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
