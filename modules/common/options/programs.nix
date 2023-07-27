{lib, ...}:
with lib; {
  # this module provides overrides for certain defaults and lets you set
  # default programs for referencing in other config files.
  options.modules = {
    services = {
      smb = {
        enable = mkEnableOption "Enables smb shares";
        host.enable = mkEnableOption "Enables hosting of smb shares";

        # should smb shares be enabled as a recpient machine
        recive = {
          general = mkEnableOption "genral share";
          media = mkEnableOption "media share";
        };
      };

      jellyfin.enable = mkEnableOption "Enables the jellyfin service"; # TODO

      cloudflare = {
        enable = mkEnableOption "Enables cloudflared tunnels";
        token = mkOption {
          type = types.str;
          default = "";
          description = "The token which is used by cloudflared tunnels";
        };
      };

      vscode-server.enable = mkEnableOption "Enables remote ssh vscode server";
    };

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

      nur = {
        enable = mkEnableOption "Use nur for extra packages";
        bella = mkEnableOption "Enable the isabelroses nur extra packages";
        nekowinston = mkEnableOption "Enables the nekowinston nur extra packages";
      };

      # default program options
      default = {
        # what program should be used as the default terminal
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
          type = types.enum ["nvim" "codium"];
          default = "nvim";
        };

        bar = mkOption {
          type = types.enum ["eww" "waybar"];
          default = "eww";
        };
      };
    };
  };
}
