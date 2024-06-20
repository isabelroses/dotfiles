{ lib, defaults, ... }:
let
  inherit (lib.lists) optionals;

  ags = "ags -b hypr";
  eags = "exec, ${ags}";
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
        ", XF86AudioMute, exec, pamixer -t"
        "$mod, escape, exec, wlogout"
        "$mod, period, exec, killall rofi || rofi -show emoji -emoji-format '{emoji}' -modi emoji"
      ]
      ++ optionals (defaults.bar == "ags") [
        "$mod, D, ${eags} -t applauncher"
        "$mod, escape, ${eags} -t powermenu"
        "$mod SHIFT, R, ${eags} --quit ; ${ags}"
        ", Xf86AudioMute, ${eags} -r 'volume.master.toggleMute(); indicator.display()'"
      ]
      ++ optionals (defaults.bar != "ags") [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

    bindle = optionals (defaults.bar == "ags") [
      ", XF86MonBrightnessUp, ${eags} -r 'brightness.screen += 0.05; indicator.display()'"
      ", XF86MonBrightnessDown, ${eags} -r 'brightness.screen -= 0.05; indicator.display()'"
      ", XF86AudioRaiseVolume, ${eags} -r 'audio.speaker.volume += 0.05; indicator.speaker()'"
      ", XF86AudioLowerVolume, ${eags} -r 'audio.speaker.volume -= 0.05; indicator.speaker()'"
    ];

    bindl = optionals (defaults.bar == "ags") [
      ", XF86AudioPlay, ${eags} -r 'mpris?.playPause()'"
      ", XF86AudioStop, ${eags} -r 'mpris?.stop()'"
      ", XF86AudioPause, ${eags} -r 'mpris?.pause()'"
      ", XF86AudioPrev, ${eags} -r 'mpris.?.previous()'"
      ", XF86AudioNext, ${eags} -r 'mpris.?.next()'"
    ];

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # hold to repeat action buttons
    binde = optionals (defaults.bar == "waybar") [
      ", XF86AudioRaiseVolume, exec, pamixer -i 5"
      ", XF86AudioLowerVolume, exec, pamixer -d 5"
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+ -q"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%- -q"
    ];
  };
}
