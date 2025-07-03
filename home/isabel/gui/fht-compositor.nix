{
  lib,
  pkgs,
  config,
  inputs,
  osConfig,
  ...
}:
let
  inherit (config.garden.programs) defaults;
in
{
  imports = [ inputs.fht-compositor.homeModules.default ];

  config = lib.mkIf config.programs.fht-compositor.enable {
    garden.packages = {
      inherit (pkgs) cosmic-files;
    };

    programs.fht-compositor = {
      settings = {
        cursor = { inherit (config.home.pointerCursor) name size; };

        autostart = [
          "wl-paste --type text --watch cliphist store" # Stores only text data
          "wl-paste --type image --watch cliphist store" # Stores only image data
        ];

        input.keyboard = {
          layout = osConfig.garden.device.keyboard;
          repeat-rate = 50;
          repeat-delay = 250;
        };

        general = {
          inner-gaps = 15;
          outer-gaps = 15;
        };

        decorations = {
          decoration-mode = "force-server-side";

          border = {
            thickness = 2;
            radius = 15;
            focused-color = "#ea76cb";
            normal-color = "#bcc0cc";
          };

          shadow = {
            sigma = 30;
            color = "#11111B";
            floating-only = false;
          };

          blur = {
            radius = 10;
            passes = 2;
            noise = 0.12;
          };
        };

        keybinds = {
          Super-q = "close-focused-window";
          Super-Shift-q = "quit";
          Super-Space = "float-focused-window";

          Super-Ctrl-r = "reload-config";

          Super-d = {
            action = "run-command";
            arg = "qs ipc call launcher toggle";
          };

          Super-Return = {
            action = "run-command";
            arg = defaults.terminal;
          };

          Super-b = {
            action = "run-command";
            arg = defaults.browser;
          };

          Super-e = {
            action = "run-command";
            arg = defaults.fileManager;
          };

          Super-Shift-s = {
            action = "run-command";
            arg = ''grim -g "`slurp -o`" - | wl-copy --type image/png'';
          };

          XF86AudioRaiseVolume = {
            action = "run-command";
            arg = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
            allow-while-locked = true;
            repeat = true;
          };
          XF86AudioLowerVolume = {
            action = "run-command";
            arg = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            allow-while-locked = true;
            repeat = true;
          };

          Super-1 = {
            action = "focus-workspace";
            arg = 0;
          };
          Super-2 = {
            action = "focus-workspace";
            arg = 1;
          };
          Super-3 = {
            action = "focus-workspace";
            arg = 2;
          };
          Super-4 = {
            action = "focus-workspace";
            arg = 3;
          };
          Super-5 = {
            action = "focus-workspace";
            arg = 4;
          };
          Super-6 = {
            action = "focus-workspace";
            arg = 5;
          };
          Super-7 = {
            action = "focus-workspace";
            arg = 6;
          };
          Super-8 = {
            action = "focus-workspace";
            arg = 7;
          };
          Super-9 = {
            action = "focus-workspace";
            arg = 8;
          };

          # Sending windows to workspaces
          Super-Shift-1 = {
            action = "send-to-workspace";
            arg = 0;
          };
          Super-Shift-2 = {
            action = "send-to-workspace";
            arg = 1;
          };
          Super-Shift-3 = {
            action = "send-to-workspace";
            arg = 2;
          };
          Super-Shift-4 = {
            action = "send-to-workspace";
            arg = 3;
          };
          Super-Shift-5 = {
            action = "send-to-workspace";
            arg = 4;
          };
          Super-Shift-6 = {
            action = "send-to-workspace";
            arg = 5;
          };
          Super-Shift-7 = {
            action = "send-to-workspace";
            arg = 6;
          };
          Super-Shift-8 = {
            action = "send-to-workspace";
            arg = 7;
          };
          Super-Shift-9 = {
            action = "send-to-workspace";
            arg = 8;
          };
        };

        mousebinds = {
          Super-Left = "swap-tile";
          Super-Right = "resize-tile";
        };

        rules = [
          {
            match-title = [
              "Bluetooth Devicecs"
              "Picture-in-Picture"
            ];
            match-app-id = [
              "^(org.gnome.*)$"
              "file_progress"
              "confirm"
              "dialog"
              "download"
              "pinentry"
              "splash"
              "bitwarden"
              "pwvucontrol"
            ];
            floating = true;
            centered = true;
          }
        ];
      };
    };

    systemd.user.services.xwayland-sattelite = {
      Unit = {
        Description = "Xwayland sattelite service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        BindsTo = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };
      Install.WantedBy = [
        "graphical-session.target"
        "fht-compositor.service"
      ];
      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        StandardOutput = "jounral";
      };
    };
  };
}
