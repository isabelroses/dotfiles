{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  imports = [
    ./defaults
    ./per-program

    ./gaming.nix
  ];

  options.modules.programs = {
    cli = {
      enable = mkEnableOption "Enable CLI programs" // {default = true;};
      modernShell.enable = mkEnableOption "Enable modern shell programs";
    };

    tui.enable = mkEnableOption "Enable TUI programs" // {default = true;};
    gui.enable = mkEnableOption "Enable GUI programs";
  };
}
