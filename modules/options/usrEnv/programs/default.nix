{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  imports = [
    ./defaults
  ];

  options.modules.usrEnv.programs = {
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

    gaming = let
      cfg = config.modules.usrEnv.programs.gaming;
    in {
      enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
      emulation.enable = mkEnableOption "Enable programs required to emulate other platforms";
      minecraft.enable = mkEnableOption "Enable minecraft";

      gamescope.enable = mkEnableOption "Gamescope compositing manager" // {default = cfg.enable;};
      steam.enable = mkEnableOption "Enable Steam" // {default = cfg.enable;};
      mangohud.enable = mkEnableOption "Enable MangoHud" // {default = cfg.enable;};
    };

    nur = {
      enable = mkEnableOption "Use nur for extra packages";
      bella = mkEnableOption "Enable the isabelroses nur extra packages";
      nekowinston = mkEnableOption "Enables the nekowinston nur extra packages";
    };
  };
}
