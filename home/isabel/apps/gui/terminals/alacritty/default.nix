{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [alacritty];
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
          dim_foreground = "#CDD6F4";
          bright_foreground = "#CDD6F4";

          cursor = {
            text = "#1E1E2E";
            cursor = "#F5E0DC";
          };

          search = {
            matches = {
              foreground = "#1E1E2E";
              background = "#A6ADC8";
            };
            focused_match = {
              foreground = "#1E1E2E";
              background = "#A6E3A1";
            };
            footer_bar = {
              foreground = "#1E1E2E";
              background = "#A6ADC8";
            };
          };
        };

        hints = {
          start = {
            foreground = "#1E1E2E";
            background = "#F9E2AF";
          };
          end = {
            foreground = "#1E1E2E";
            background = "#A6ADC8";
          };
        };

        selection = {
          text = "#1E1E2E";
          background = "#F5E0DC";
        };

        normal = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };

        bright = {
          black = "#585B70";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#A6ADC8";
        };

        dim = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };

        indexed_colours = [
          {
            index = 16;
            color = "#FAB387";
          }
          {
            index = 16;
            color = "#F5E0DC";
          }
        ];
      };

      font = {
        normal = {
          family = "RobotoMono Nerd Font Mono";
          style = "Regular";
        };

        bold = {
          family = "RobotoMono Nerd Font Mono";
          style = "Bold";
        };

        italic = {
          family = "RobotoMono Nerd Font Mono";
          style = "Regular";
        };

        bold_italic = {
          family = "RobotoMono Nerd Font Mono";
          style = "Regular Bold";
        };

        size = 13.0;
      };

      cursor = {
        style = {
          shape = "Beam";
          blinking = "Off";
        };
      };

      dynamic_padding = true;
    };
  };
}
