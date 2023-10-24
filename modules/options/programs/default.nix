{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  imports = [
    ./defaults
    ./gaming.nix
  ];

  options.modules.programs = {
    cli = {
      enable = mkEnableOption "Enable CLI programs";
      modernShell.enable = mkEnableOption "Enable modern shell programs";
    };
    tui.enable = mkEnableOption "Enable TUI programs";
    gui.enable = mkEnableOption "Enable GUI programs";

    zathura.enable = mkEnableOption "Enable zathura PDF reader";

    git = {
      signingKey = mkOption {
        type = types.str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };
  };
}
