{ lib, config, ... }:
let
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.programs;
in
{
  # these are options that will cause a mass rebuild by enabling multiple packages
  options.garden.programs = {
    cli = {
      enable = mkEnableOption "Enable CLI programs" // {
        default = true;
      };
      modernShell.enable = mkEnableOption "Enable programs for a more modern shell";
    };

    tui.enable = mkEnableOption "Enable TUI programs" // {
      default = cfg.cli.enable;
    };

    gui.enable = mkEnableOption "Enable GUI programs";

    notes.enable = mkEnableOption "Enable note-taking programs";
  };
}
