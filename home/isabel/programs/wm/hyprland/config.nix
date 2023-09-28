{
  config,
  osConfig,
  lib,
  defaults,
  ...
}: let
  inherit (lib) imap0 optionalString optionals;

  pointer = config.home.pointerCursor;
  dev = osConfig.modules.device;
  inherit (osConfig.modules.device) monitors;
in {
  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "SUPER";
      "$teal" = "0xff94e2d5";
      "$sky" = "0xff89dceb";
      "$sapphire" = "0xff74c7ec";
      "$blue" = "0xff89b4fa";
      "$surface1" = "0xff45475a";
      "$surface0" = "0xff313244";

      exec-once =
        [
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          "wlsunset -S 8:00 -s 20:00"
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        ]
        ++ optionals (defaults.bar == "eww") [
          "~/.config/eww/scripts/init"
        ]
        ++ optionals (defaults.bar == "waybar") [
          "waybar"
        ]
        ++ optionals (defaults.bar == "ags") [
          "ags"
        ];

      input = {
        kb_layout = "${dev.keyboard}";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          tap-to-click = true;
          natural_scroll = false; # this is not natrual
          disable_while_typing = false;
        };
      };

      gestures.workspace_swipe = dev.type == "laptop" || dev.type == "hybrid";

      general = {
        layout = "master";

        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        no_border_on_floating = true;

        "col.active_border" = "$sapphire";
        "col.inactive_border" = "$surface0";
        "col.group_border_active" = "$blue";
        "col.group_border" = "$surface0";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;

        # window swallowing
        enable_swallow = true; # hide windows that spawn other windows
        swallow_regex = "foot|thunar|nemo";

        # dpms
        mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
        key_press_enables_dpms = true; # enable dpms on keyboard action
        disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      };

      decoration = {
        rounding = 10;
        multisample_edges = true;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        blur = {
          enabled = true;
          passes = 1;
          size = 2;
          new_optimizations = true;
        };

        blurls = [
          "eww_powermenu"
          "eww_takeshot"
        ];

        drop_shadow = true;
        "col.shadow" = "$surface1";
        "col.shadow_inactive" = "$surface1";
      };

      animations = {
        enabled = !(dev.type == "laptop");

        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.1"
        ];

        animation = [
          "windows, 1, 8, overshot, popin"
          # "fade, 1, 8, overshot"
          "workspaces, 1, 8, overshot, slide"
        ];
      };

      master = {
        no_gaps_when_only = false;
        new_is_master = true;
      };

      dwindle = {
        no_gaps_when_only = false;
        pseudotile = true;
        preserve_split = true;
      };

      windowrule = [
        "float, ^(Rofi)$"
        "float, ^(eww)$"
        "float, ^(pavucontrol)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(blueberry.py)$"
        "float, ^(org.gnome.Settings)$"
        "float, ^(org.gnome.design.Palette)$"
        "float, ^(Color Picker)$"
        "float, ^(Network)$"
        "float, ^(xdg-desktop-portal)$"
        "float, ^(xdg-desktop-portal-gnome)$"
        "float, ^(transmission-gtk)$"
        "float, ^(ags)$"
        "float, Bitwarden"
        "size 800 600,class:Bitwarden"
      ];

      windowrulev2 = [
        "workspace 6, title:^(.*(Disc|WebC)ord.*)$"

        # throw sharing indicators away
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
      ];

      bind =
        [
          # launchers
          "$mod, B, exec, ${defaults.browser}"
          "$mod, E, exec, ${defaults.fileManager}"
          "$mod, C, exec, ${defaults.editor}"
          "$mod, Return, exec, ${defaults.terminal}"
          "$mod, L, exec, ${defaults.screenLocker}"
          "$mod, O, exec, obsidian"

          # window managment
          "$mod, Q, killactive,"
          # "$mod SHIFT, Q, exit,"
          "$mod SHIFT, c, exec, hyprctl reload"
          "$mod, F, fullscreen,"
          "$mod, Space, togglefloating,"
          "$mod, P, pseudo," # dwindle
          "$mod, S, togglesplit," # dwindle

          # grouping
          "$mod, g, togglegroup"
          "bind= $mod, tab, changegroupactive"

          # special workspace stuff
          "$mod, grave, togglespecialworkspace"
          "$mod SHIFT, grave, movetoworkspace, special"

          # scroll wheel binds
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ]
        ++ optionals (defaults.bar == "eww") [
          "$mod, D, exec, ~/.config/eww/scripts/launcher toggle_menu app_launcher"
          "$mod SHIFT, R, exec, ~/.config/eww/scripts/init"
          "$mod, V, exec, ~/.config/eww/scripts/launcher clipboard"
          "$mod, escape, exec, ~/.config/eww/scripts/launcher toggle_menu powermenu"
          "$mod shift, d, exec, ~/.config/eww/scripts/notifications closeLatest"
          ", XF86AudioMute, exec, ~/.config/eww/scripts/volume mute"

          # screenshot
          ", PRINT, exec, ~/.config/eww/scripts/launcher toggle_menu takeshot"
          "shift, PRINT, exec, ~/.config/eww/scripts/screenshot screen-quiet"
          "super shift, S, exec, ~/.config/eww/scripts/screenshot area-quiet"
        ]
        ++ optionals (defaults.bar == "waybar") [
          "$mod, D, exec, rofi -show drun"
          "$mod, escape, exec, wlogout"
          "$mod, period, exec, killall rofi || rofi -show emoji -emoji-format '{emoji}' -modi emoji"
        ]
        ++ optionals (defaults.bar == "ags") [
          "$mod, D, exec, ags toggle-window applauncher"
          "$mod, escape, exec, ags toggle-window powermenu"
          "$mod SHIFT, R, exec, ags quit ; ags"
        ]
        ++ optionals (defaults.bar != "eww") [
          ", XF86AudioMute, exec, pamixer -t"
          ", Print, exec, grim -g '$(slurp)' - | swappy -f -"
          "$mod, V, exec, cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"
        ]
        ++ optionals (defaults.bar != "ags") [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

      bindle =
        []
        ++ optionals (defaults.bar == "ags") [
          ", XF86MonBrightnessUp, exec, ags run-js 'ags.Service.Brightness.screen += 0.02; ags.Service.Indicator.display()'"
          ", XF86MonBrightnessDown, exec, ags run-js 'ags.Service.Brightness.screen -= 0.02; ags.Service.Indicator.display()'"
          ", XF86AudioRaiseVolume, exec, ags run-js 'ags.Service.Audio.speaker.volume += 0.05; ags.Service.Indicator.speaker()'"
          ", XF86AudioLowerVolume, exec, ags run-js 'ags.Service.Audio.speaker.volume -= 0.05; ags.Service.Indicator.speaker()'"
        ];

      bindl =
        []
        ++ optionals (defaults.bar == "ags") [
          ", XF86AudioPlay, exec, ags run-js `ags.Service.Mpris.getPlayer()?.playPause()`"
          ", XF86AudioStop, exec, ags run-js `ags.Service.Mpris.getPlayer()?.stop()`"
          ", XF86AudioPause, exec, ags run-js `ags.Service.Mpris.getPlayer()?.pause()`"
          ", XF86AudioPrev, exec, ags run-js `ags.Service.Mpris.getPlayer()?.previous()`"
          ", XF86AudioNext, exec, ags run-js `ags.Service.Mpris.getPlayer()?.next()`"
        ];

      # mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # hold to repeat action buttons
      binde =
        []
        ++ optionals (defaults.bar == "eww") [
          ", XF86AudioRaiseVolume, exec, ~/.config/eww/scripts/volume up"
          ", XF86AudioLowerVolume, exec, ~/.config/eww/scripts/volume down"
          ", XF86MonBrightnessUp, exec, ~/.config/eww/scripts/brightness up"
          ", XF86MonBrightnessDown, exec, ~/.config/eww/scripts/brightness down"
        ]
        ++ optionals (defaults.bar == "waybar") [
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+ -q"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%- -q"
        ];
    };

    extraConfig = let
      mapMonitors = builtins.concatStringsSep "\n" (imap0 (i: monitor: ''monitor=${monitor},${
          if monitor == "DP-1"
          then "1920x1080@144"
          else "preferred"
        },${toString (i * 1920)}x0,1'') monitors);

      mapMonitorsToWs = builtins.concatStringsSep "\n" (
        builtins.genList (
          x: ''
            workspace = ${toString (x + 1)}, monitor:${
              if (x + 1) <= 5
              then "${builtins.elemAt monitors 0} ${
                if (x + 1) == 1
                then ", default:true"
                else ""
              }"
              else "${builtins.elemAt monitors 1}"
            }

          ''
        )
        10
      );
    in ''
      ${mapMonitors}
      ${optionalString (builtins.length monitors != 1) "${mapMonitorsToWs}"}

      # █▀▄▀█ █▀█ █░█ █▀▀
      # █░▀░█ █▄█ ▀▄▀ ██▄
      bind=$mod, M, submap, move
      submap=move

        binde = , left, movewindow, l
        binde = , right, movewindow, r
        binde = , up, movewindow, u
        binde = , down, movewindow, d
        binde = , j, movewindow, l
        binde = , l, movewindow, r
        binde = , i, movewindow, u
        binde = , k, movewindow, d

        bind=,escape,submap,reset
      submap=reset

      # █▀█ █▀▀ █▀ █ ▀█ █▀▀
      # █▀▄ ██▄ ▄█ █ █▄ ██▄
      bind=SUPER, R, submap, resize
      submap=resize

        binde = , left, resizeactive, -20 0
        binde = , right, resizeactive, 20 0
        binde = , up, resizeactive, 0 -20
        binde = , down, resizeactive, 0 20
        binde = , h, resizeactive, -20 0
        binde = , j, resizeactive, 20 0
        binde = , i, resizeactive, 0 -20
        binde = , k, resizeactive, 0 20

        bind=,escape,submap,reset
      submap=reset

      ${
        builtins.concatStringsSep "\n" (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in ''
              bind = $mod, ${ws}, workspace, ${toString (x + 1)}
              bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
            ''
          )
          10)
      }
    '';
  };
}
