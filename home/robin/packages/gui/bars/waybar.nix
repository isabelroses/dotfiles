{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;

  inherit (osConfig.garden.style) font;
  cfg = config.garden.programs.waybar;
in
{
  config = mkIf (isWayland osConfig && cfg.enable) {
    home.packages = [ pkgs.wlogout ];

    programs.waybar = {
      enable = true;
      inherit (cfg) package;

      systemd.enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 5;

        spacing = 5;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 2;
        margin-right = 2;

        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "wireplumber"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          active-only = false;
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
            sort-by-number = true;
          };
        };

        tray = {
          icon-size = 20;
          spacing = 8;
        };

        clock = {
          format = "{: %R}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        wireplumber = {
          format = "{volume}% {icon}";
          tooltip = false;
          format-muted = "󰝟";
          on-click = lib.getExe pkgs.pwvucontrol;
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          scroll-step = 5;
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
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
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };
        "custom/launcher" = {
          format = "";
          on-click = "pkill rofi || rofi -show drun -show-icons";
          on-click-right = "pkill rofi || rofi -show drun -show-icons";
          tooltip = "false";
        };
      };

      style =
        let
          custom = {
            font_weight = "bold";
            text_color = "#cdd6f4";
            secondary_accent = "#89b4fa";
            tertiary_accent = "#f5f5f5";
            background = "#11111B";
            opacity = "0.98";
          };
        in
        ''
          * {
              border: none;
              border-radius: 0px;
              padding: 0;
              margin: 0;
              min-height: 0px;
              font-family: ${font.name};
              font-weight: ${custom.font_weight};
              opacity: ${custom.opacity};
          }

          window#waybar {
              background: none;
          }

          #workspaces {
              font-size: ${toString font.size}px;
              padding-left: 15px;
          }
          #workspaces button {
              color: ${custom.text_color};
              padding-left:  6px;
              padding-right: 6px;
          }
          #workspaces button.empty {
              color: #6c7086;
          }
          #workspaces button.active {
              color: #b4befe;
          }

          #tray, #wireplumber, #network, #cpu, #custom-temperature, #disk, #clock {
              font-size: ${toString font.size}px;
              color: ${custom.text_color};
          }

          #tray {
              padding: 0 16px;
              padding-right: 12px;
              margin-left: 7px;
          }

          #wireplumber {
              font-size: ${toString font.size}px;
              padding-left: 15px;
              padding-right: 9px;
              margin-left: 7px;
          }
          #network {
              padding-left: 9px;
              padding-right: 15px;
          }

          #clock {
              padding-left: 9px;
              padding-right: 15px;
          }

          #custom-launcher {
              font-size: 18px;
              color: #b4befe;
              font-weight: ${custom.font_weight};
              padding-left: 10px;
              padding-right: 12px;
          }
        '';
    };
  };
}
