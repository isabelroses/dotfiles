{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib)
    length
    optionalString
    elemAt
    genList
    concatLists
    imap0
    concatLines
    ;

  mod = "SUPER";
  pointer = config.home.pointerCursor;
  inherit (config.garden.programs) defaults;
  inherit (osConfig.garden.device) monitors keyboard;
in
{
  options.programs.hyprland.enable = lib.mkEnableOption "Enable Hyprland as the Wayland window manager";

  config = lib.mkIf config.programs.hyprland.enable {
    garden.packages = { inherit (pkgs) swww hyprpicker cosmic-files; };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      settings = {
        animations = {
          enabled = true;

          bezier = [
            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"
          ];
          animation = [
            "windows, 1, 6, wind, slide"
            "windowsIn, 1, 6, winIn, slide"
            "windowsOut, 1, 5, winOut, slide"
            "windowsMove, 1, 5, wind, slide"
            "border, 1, 1, liner"
            "borderangle, 1, 30, liner, loop"
            "fade, 1, 10, default"
            "workspaces, 1, 5, wind"
          ];
        };

        bind = [
          # launchers
          "${mod}, D, exec, vicinae open"
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

        decoration = {
          rounding = 15;

          # 0.8 is nice if we opacity
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          fullscreen_opacity = 1.0;

          shadow = {
            enabled = true;
            color = "rgb(11111B)";
            color_inactive = "rgba(11111B00)";
          };

          blur = {
            enabled = true;
            passes = 2;
            size = 2;

            brightness = 1;
            contrast = 1.3;
            noise = 1.17e-2;
            ignore_opacity = true;

            new_optimizations = true;
            xray = true;
          };
        };

        exec-once = [
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
          "swww-daemon"
        ];

        general = {
          layout = "master";

          gaps_in = 8;
          gaps_out = 8;
          gaps_workspaces = 0;
          border_size = 2;
          no_border_on_floating = true;

          "col.active_border" = "$pink";
          "col.inactive_border" = "$surface1";
        };

        group = {
          insert_after_current = true;
          # focus on the window that has just been moved out of the group
          focus_removed_window = true;

          "col.border_active" = "$rosewater";
          "col.border_inactive" = "$surface1";

          groupbar = {
            gradients = false;
            font_size = 12;

            render_titles = false;
            scrolling = true; # change focused window with scroll
          };
        };

        input = {
          kb_layout = keyboard;
          follow_mouse = 1;
          sensitivity = if keyboard == "us" then -0.8 else 0; # -1.0 - 1.0, 0 means no modification.
          numlock_by_default = true; # numlock enable

          # swap caps lock and escape
          # kb_options = "caps:swapescape";

          touchpad = {
            tap-to-click = true;
            natural_scroll = false; # this is not natural
            disable_while_typing = false; # this is annoying
          };
        };

        cursor = {
          no_hardware_cursors = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;

          # window swallowing
          enable_swallow = true; # hide windows that spawn other windows
          swallow_regex = "wezterm|foot|cosmic-files|nemo";

          # dpms
          mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
          key_press_enables_dpms = true; # enable dpms on keyboard action
          disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
        };
      };

      extraConfig =
        let
          mapMonitors = concatLines (
            imap0 (
              i: monitor:
              ''monitor=${monitor},${
                if monitor == "eDP-1" then "1920x1080@60" else "preferred"
              },${toString (i * 1920)}x0,1''
            ) monitors
          );

          mapMonitorsToWs = concatLines (
            genList (x: ''
              workspace = ${toString (x + 1)}, monitor:${
                if (x + 1) <= 5 then
                  "${elemAt monitors 0} ${if (x + 1) == 1 then ", default:true" else ""}"
                else
                  "${elemAt monitors 1}"
              }
            '') 10
          );

        in
        ''
          ${mapMonitors}
          ${optionalString (length monitors != 1) "${mapMonitorsToWs}"}

          # █▀▄▀█ █▀█ █░█ █▀▀
          # █░▀░█ █▄█ ▀▄▀ ██▄
          bind=SUPER, M, submap, move
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
        '';
    };
  };
}
