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
    mod
    attrNames
    attrValues
    foldl'
    min
    id
    ;

  inherit (config.garden.programs) defaults;
  inherit (osConfig.garden.device) monitors keyboard;

  mapMonitors = concatLines (
    imap0 (
      i: m:
      "monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refresh-rate},${toString (i * 1920)}x0,${toString m.scale}"
    ) (attrValues monitors)
  );

  mapMonitorsToWs =
    let
      names = attrNames monitors;
      count = length names;
      splitBy = builtins.div 10 count;
      remainder = mod 10 count;
      firstSplitBy = splitBy + remainder;
    in
    concatLines
      (foldl'
        (
          acc: i:
          let
            currentSplitBy = if acc.elem == 0 then firstSplitBy else splitBy;
            shouldIncrement = acc.usedFor >= currentSplitBy;
            newElem = min (if shouldIncrement then acc.elem + 1 else acc.elem) (count - 1);
            asStr = "workspace=${toString (i + 1)}, monitor:${elemAt names newElem}${
              if i == 0 then ", default:true" else ""
            }";
          in
          {
            usedFor = if shouldIncrement then 1 else acc.usedFor + 1;
            elem = newElem;
            out = acc.out ++ [ asStr ];
          }
        )
        {
          usedFor = 0;
          elem = 0;
          out = [ ];
        }
        (genList id 10)
      ).out;
in
{
  options.programs.hyprland.enable = lib.mkEnableOption "Enable Hyprland as the Wayland window manager";

  config = lib.mkIf config.programs.hyprland.enable {
    garden.packages = { inherit (pkgs) hyprpicker cosmic-files; };

    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;

      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      settings = {
        "$mod" = "SUPER";

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
          "$mod, D, exec, vicinae toggle"
          "$mod, B, exec, ${defaults.browser}"
          "$mod, E, exec, ${defaults.fileManager}"
          "$mod, C, exec, ${defaults.editor}"
          "$mod, Return, exec, ${defaults.terminal}"
          "$mod, L, exec, ${defaults.screenLocker}"
          "$mod, O, exec, obsidian"
          "$mod SHIFT, V, exec, vicinae deeplink vicinae://extensions/vicinae/clipboard/history"

          # window management
          "$mod, Q, killactive,"
          # "$mod SHIFT, Q, exit,"
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

          # screen shot
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mod SHIFT, s, exec, grim -g \"$(slurp)\" - | wl-copy"

          # scroll wheel binds
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

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
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) 10
        ));

        # mouse binds
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
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
          active_opacity = 1.00;
          inactive_opacity = 1.00;
          fullscreen_opacity = 1.00;

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

        layerrule = [
          "blur,vicinae"
          "ignorealpha 0, vicinae"
          "noanim, vicinae"
        ];

        general = {
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

        gesture = [
          "3,horizontal,workspace"
          "4,horizontal,workspace"
        ];

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          enable_anr_dialog = false;

          # window swallowing
          enable_swallow = false; # hide windows that spawn other windows
          swallow_regex = "wezterm|foot|cosmic-files|nemo|com\.mitchellh\.ghostty";

          # dpms
          mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
          key_press_enables_dpms = true; # enable dpms on keyboard action
          disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
        };

        windowrulev2 = [
          "float, title:^(nm-connection-editor)$"
          "float, title:^(Network)$"
          "float, title:^(xdg-desktop-portal-gtk)$"
          "float, class:gay.vaskel.soteria"
          "float, title:^(Picture-in-Picture)$"
          "float, class:^(download)$"

          "center(1), initialTitle:(Open Files)"
          "float, initialTitle:(Open Files)"
          "size 40% 60%, initialTitle:(Open Files)"

          "center(1), class:.blueman-manager-wrapped"
          "float, class:.blueman-manager-wrapped"
          "size 40% 60%, class:.blueman-manager-wrapped"

          "center(1), class:com.saivert.pwvucontrol"
          "float, class:com.saivert.pwvucontrol"
          "size 40% 60%, class:com.saivert.pwvucontrol"

          # we can't just use the tag because we want to capture the popup window
          "float, title:Bitwarden"
          "size 800 600, title:Bitwarden"
          # "no_screenshare on, tag:bitwarden"

          "workspace 6, class:discord" # move discord to workspace 6
          "workspace 7, class:spotify" # move spotify to workspace 7

          # throw sharing indicators away
          "workspace special silent, title:^(Firefox — Sharing Indicator)$"
          "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
        ];
      };

      extraConfig = ''
        ${mapMonitors}
        ${optionalString (length (attrNames monitors) != 1) "${mapMonitorsToWs}"}

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
