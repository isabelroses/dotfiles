{
  config.modules = {
    device.type = "laptop";

    system = {
      mainUser = "isabel";
    };

    environment = {
      desktop = "yabai";
      useHomeManager = true;
    };

    programs = {
      agnostic = {
        git.signingKey = "5A87C993E20D89A1";

        editors = {
          neovim.enable = true;
          vscode.enable = false;
          micro.enable = false;
        };

        wine.enable = false;
      };

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;

      gui = {
        enable = false;

        zathura.enable = false;
        discord.enable = true;

        kdeconnect = {
          enable = false;
          indicator.enable = false;
        };

        launchers = {
          rofi.enable = false;
          wofi.enable = false;
        };

        bars = {
          ags.enable = false;
          waybar.enable = false;
        };

        browsers = {
          chromium = {
            enable = false;
            ungoogled = false;
          };

          firefox = {
            enable = false;
            schizofox = false;
          };
        };

        terminals = {
          kitty.enable = false;
          alacritty.enable = false;
          wezterm.enable = true;
          ghostty.enable = true;
        };

        fileManagers = {
          thunar.enable = false;
          dolphin.enable = false;
          nemo.enable = false;
        };
      };
    };
  };
}
