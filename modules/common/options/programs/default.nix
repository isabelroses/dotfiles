{lib, ...}:
with lib; {
  imports = [./services.nix];
  # this module provides overrides for certain defaults and lets you set
  # default programs for referencing in other config files.
  options.modules = {
    programs = {
      # "override" is a simple option that sets the programs' state to the oppossite of their default
      override = {
        # override basic desktop applications
        # an example override for the libreoffice program
        # if set to true, libreoffice module will not be enabled as it is by default
        libreoffice = mkEnableOption "Override Libreoffice suite";
      };

      # TODO: turn those into overrides
      # load GUI and CLI programs by default, but check if those overrides are enabled
      # so that they can be disabled at will
      cli = {
        enable = mkEnableOption "Enable CLI programs";
      };
      gui = {
        enable = mkEnableOption "Enable GUI programs";
      };

      gaming = {
        enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
        gamescope.enable = mkEnableOption "Gamescope compositing manager" // {default = config.modules.programs.gaming.enable;};
      };

      git = {
        signingKey = mkOption {
          type = types.str;
          default = "";
          description = "The default gpg key used for signing commits";
        };
      };

      nur = {
        enable = mkEnableOption "Use nur for extra packages";
        bella = mkEnableOption "Enable the isabelroses nur extra packages";
        nekowinston = mkEnableOption "Enables the nekowinston nur extra packages";
      };

      # default program options
      default = {
        # what program should be used as the default terminal
        terminal = mkOption {
          type = types.enum ["alacritty" "kitty" "wezterm" "foot"];
          default = "kitty";
        };

        fileManager = mkOption {
          type = types.enum ["thunar" "dolphin" "nemo"];
          default = "thunar";
        };

        browser = mkOption {
          type = types.enum ["firefox" "chromium"];
          default = "chromium";
        };

        editor = mkOption {
          type = types.enum ["nvim" "codium"];
          default = "nvim";
        };

        launcher = mkOption {
          type = types.enum ["rofi" "wofi"];
          default = "rofi";
        };

        bar = mkOption {
          type = types.enum ["eww" "waybar" "ags"];
          default = "eww";
        };
      };
    };
  };
}
