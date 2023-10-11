{
  pkgs,
  lib,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) optionalString;
  sys = osConfig.modules.system;
  cfg = osConfig.modules.programs;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isWayland osConfig && defaults.bar == "waybar") {
    home.packages = with pkgs; [wlogout];

    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      systemd.enable = true;
      style = import ./style.nix {};
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          exclusive = true;
          passthrough = false;
          gtk-layer-shell = true;
          margin-left = 2;
          margin-right = 2;
          height = 0;
          modules-left = [
            "custom/launcher"
          ];
          modules-center = [
            "hyprland/workspaces"
          ];
          modules-right = [
            "tray"
            "backlight"
            (optionalString sys.bluetooth.enable "bluetooth")
            (optionalString cfg.gaming.enable "gamemode")
            "pulseaudio"
            "battery"
            "clock"
            "custom/logout"
          ];
          "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 20;
            "icon-theme" = "Star";
            "tooltip-format" = "{title}";
            "on-click" = "minimize";
            "on-click-middle" = "close";
            "on-click-right" = "activate";
          };
          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            sort-by-number = true;
            on-click = "activate";
            format = "{icon}";
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
            };
          };
          tray = {
            icon-size = 13;
            spacing = 10;
          };
          clock = {
            format = "{: %R}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            tooltip = false;
            format-muted = "󰝟";
            on-click = "pamixer -t";
            on-scroll-up = "pamixer -i 5";
            on-scroll-down = "pamixer -d 5";
            scroll-step = 5;
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
          };
          "pulseaudio#microphone" = {
            format = "{format_source}";
            format-source = " {volume}%";
            format-source-muted = " Muted";
            on-click = "pamixer --default-source -t";
            on-scroll-up = "pamixer --default-source -i 5";
            on-scroll-down = "pamixer --default-source -d 5";
            scroll-step = 5;
          };
          network = {
            interface = "wlo1";
            format-wifi = "";
            format-ethernet = "";
            tooltip-format = "{essid} ({signalStrength}%)";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "⚠";
            format-alt = "{ifname} = {ipaddr}/{cidr}";
          };
          backlight = {
            tooltip = false;
            format = "{icon} {percent}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            interval = 1;
            on-scroll-up = "brightnessctl set 1%- -q";
            on-scroll-down = "brightnessctl set 1%+ -q";
          };
          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 20;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time} {icon}";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };
          bluetooth = {
            format = "";
            format-connected-battery = " {icon}";
            battery = {
              states = {
                good = 95;
                warning = 30;
                critical = 20;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-alt = "{time} {icon}";
              format-icons = ["" "" "" "" "" "" "" "" "" "" ""];
            };
            tooltip-format = "{controller_alias}\t{controller_address}\n{status}";
            tooltip-format-off = "{controller_alias}\t{controller_address}\n{status}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n{num_connections} {status}\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            format-icons = {
              default = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            };
            on-click = "$term -e bluetoothctl";
            on-click-right = "killall bluetoothctl";
            on-scroll-up = "bluetoothctl power on";
            on-scroll-down = "bluetoothctl power off";
          };
          "custom/logout" = {
            format = " ";
            on-click = "wlogout --protocol layer-shell -b 5 -T 400 -B 400";
            on-right-click = "wlogout --protocol layer-shell -b 5 -T 400 -B 400";
            tooltip = false;
          };
          "custom/launcher" = {
            format = "";
            on-click = "rofi -show drun";
            on-click-right = "rofi -show drun";
          };
          gamemode = {
            format = "󰊴";
            format-alt = "{glyph}";
            glyph = "󰊴";
            hide-not-running = true;
            use-icon = true;
            icon-name = "input-gaming-symbolic";
            icon-spacing = 4;
            icon-size = 20;
            tooltip = true;
            tooltip-format = "Games running: {count}";
          };
        };
      };
    };
  };
}
