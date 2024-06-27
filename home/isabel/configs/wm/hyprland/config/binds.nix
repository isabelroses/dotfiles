{ lib, defaults, ... }:
let
  inherit (lib.lists) optionals;
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind =
      [
        # launchers
        "$mod, B, exec, ${defaults.browser}"
        "$mod, E, exec, ${defaults.fileManager}"
        "$mod, C, exec, ${defaults.editor}"
        "$mod, Return, exec, ${defaults.terminal}"
        "$mod, L, exec, ${defaults.screenLocker}"
        "$mod, O, exec, obsidian"

        # window management
        "$mod, Q, killactive,"
        # "$mod SHIFT, Q, exit,"
        "$mod SHIFT, c, exec, hyprctl reload"
        "$mod, F, fullscreen,"
        "$mod, Space, togglefloating,"
        "$mod, P, pseudo," # dwindle
        "$mod, S, togglesplit," # dwindle

        # grouping
        "$mod, g, togglegroup"
        "$mod, tab, changegroupactive"

        # special workspace stuff
        "$mod, grave, togglespecialworkspace"
        "$mod SHIFT, grave, movetoworkspace, special"

        # scroll wheel binds
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ]
      ++ optionals (defaults.bar == "waybar") [
        "$mod, D, exec, rofi -show drun"
        ", XF86AudioMute, exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "$mod, escape, exec, wlogout"
        "$mod, period, exec, killall rofi || rofi -show emoji -emoji-format '{emoji}' -modi emoji"
      ]
      ++ optionals (defaults.bar == "ags") [
        "$mod, D, $ -t applauncher"
        "$mod, escape, exec ags -t powermenu"
        "$mod SHIFT, R, exec ags --quit ; ags"
        ", Xf86AudioMute, exec ags -r 'volume.master.toggleMute(); indicator.display()'"
      ]
      ++ optionals (defaults.bar != "ags") [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

    bindle = optionals (defaults.bar == "ags") [
      ", XF86MonBrightnessUp, exec ags -r 'brightness.screen += 0.05; indicator.display()'"
      ", XF86MonBrightnessDown, exec ags -r 'brightness.screen -= 0.05; indicator.display()'"
      ", XF86AudioRaiseVolume, exec ags -r 'audio.speaker.volume += 0.05; indicator.speaker()'"
      ", XF86AudioLowerVolume, exec ags -r 'audio.speaker.volume -= 0.05; indicator.speaker()'"
    ];

    bindl = optionals (defaults.bar == "ags") [
      ", XF86AudioPlay, exec ags -r 'mpris?.playPause()'"
      ", XF86AudioStop, exec ags -r 'mpris?.stop()'"
      ", XF86AudioPause, exec ags -r 'mpris?.pause()'"
      ", XF86AudioPrev, exec ags -r 'mpris.?.previous()'"
      ", XF86AudioNext, exec ags -r 'mpris.?.next()'"
    ];

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # hold to repeat action buttons
    binde = optionals (defaults.bar == "waybar") [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+ -q"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%- -q"
    ];
  };
}
