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

  ags = "ags -b hypr";
  eags = "exec, ${ags}";
  eww = "~/.config/eww/scripts";
  eeww = "exec, ${eww}";
in {
  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "SUPER";
      "$inactive" = "0xff45475a"; # ctp surface1

      exec-once =
        [
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          "wlsunset -S 8:00 -s 20:00"
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        ]
        ++ optionals (defaults.bar == "eww") [
          "${eww}/init"
        ]
        ++ optionals (defaults.bar == "waybar") [
          "waybar"
        ]
        ++ optionals (defaults.bar == "ags") [
          ags
        ];

      input = {
        kb_layout = "${dev.keyboard}";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          tap-to-click = true;
          natural_scroll = false; # this is not natrual
          disable_while_typing = false; # this is annoying
        };
        numlock_by_default = true; # numlock enable
      };

      gestures.workspace_swipe = dev.type == "laptop" || dev.type == "hybrid";

      general = {
        layout = "master";

        gaps_in = 8;
        gaps_out = 8;
        gaps_workspaces = 0;
        border_size = 2;
        no_border_on_floating = true;

        "col.active_border" = "rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 10deg";
        "col.inactive_border" = "$inactive";
      };

      group = {
        insert_after_current = true;
        # focus on the window that has just been moved out of the group
        focus_removed_window = true;

        "col.border_active" = "0xff89dceb";
        "col.border_inactive" = "$inactive";

        groupbar = {
          gradients = false;
          font_size = 12;

          render_titles = false;
          scrolling = true; # change focused window with scroll
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;

        # window swallowing
        enable_swallow = true; # hide windows that spawn other windows
        swallow_regex = "foot|thunar|nemo";

        # dpms
        mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
        key_press_enables_dpms = true; # enable dpms on keyboard action
        disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      };

      decoration = {
        rounding = 15;

        active_opacity = 1.0;
        inactive_opacity = 1.0;

        blur = {
          enabled = true;
          passes = 2;
          size = 2;
          new_optimizations = true;
          xray = true;
        };

        blurls = [
          "eww_powermenu"
          "eww_takeshot"
        ];

        drop_shadow = true;
        "col.shadow" = "rgb(11111B)";
        "col.shadow_inactive" = "rgba(11111B00)";
      };

      animations = {
        enabled = dev.type != "laptop";
        first_launch_animation = false;

        bezier = [
          "overshot,0.13,0.99,0.29,1.1"
        ];

        animation = [
          "windows,1,4,overshot,slide"
          "border,1,10,default"
          "fade,1,10,default"
          "workspaces,1,6,overshot,slide"
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
        "float, bitwarden"
        "float, ^(rofi)$"
        "float, ^(eww)$"
        "float, ^(pavucontrol)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(blueberry.py)$"
        "float, ^(Color Picker)$"
        "float, ^(Network)$"
        "float, ^(com.github.Aylur.ags)$"
        "float, ^(xdg-desktop-portal)$"
        "float, ^(xdg-desktop-portal-gnome)$"
        "float, ^(transmission-gtk)$"
        "size 800 600,class:Bitwarden"
      ];

      windowrulev2 = [
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(Viewnior)$"
        "float, class:^(download)$"

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
          "$mod, D, ${eeww}/launcher toggle_menu app_launcher"
          "$mod SHIFT, R, ${eeww}/init"
          "$mod, V, ${eeww}/launcher clipboard"
          "$mod, escape, ${eeww}/launcher toggle_menu powermenu"
          "$mod shift, d, ${eeww}/notifications closeLatest"
          ", XF86AudioMute, ${eeww}/volume mute"

          # screenshot
          ", PRINT, ${eeww}/launcher toggle_menu takeshot"
          "shift, PRINT, ${eeww}/screenshot screen-quiet"
          "super shift, S, ${eeww}/screenshot area-quiet"
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
        ++ optionals (defaults.bar != "eww") [
          ", Print, exec, grim -g '$(slurp)' - | swappy -f -"
          "$mod, V, exec, cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"
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
      binde =
        optionals (defaults.bar == "eww") [
          ", XF86AudioRaiseVolume, ${eeww}/volume up"
          ", XF86AudioLowerVolume, ${eeww}/volume down"
          ", XF86MonBrightnessUp, ${eeww}/brightness up"
          ", XF86MonBrightnessDown, ${eeww}/brightness down"
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
          if monitor == "eDP-1"
          then "1920x1080@60"
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
