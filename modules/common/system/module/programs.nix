{lib, ...}:
with lib; {
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

      git = {
        signingKey = mkOption {
          type = types.str;
          default = "";
          description = "The default gpg key used for signing commits";
        };
      };

      # default program options
      default = {
        # what program should be used as the default terminal
        # do note this is NOT the command, but just the name. i.e setting footclient will
        # not work because the program name will be references as "foot" in the rest of the config
        terminal = mkOption {
          type = types.enum ["alacritty" "kitty" "wezterm"];
          default = "alacritty";
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
          type = types.enum ["nvim" "code"];
          default = "nvim";
        };
      };
    };
  };
}
