{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.garden.system.printing;
in
{
  options.garden.system.printing = {
    enable = mkEnableOption "printing";

    extraDrivers = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "A list of additional drivers to install for printing";
    };
  };

  config = mkIf cfg.enable {
    # enable cups and some drivers for common printers
    services = {
      printing = {
        enable = true;

        drivers =
          with pkgs;
          [
            gutenprint
            hplip
          ]
          ++ cfg.extraDrivers;
      };

      # required for network discovery of printers
      avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };
    };
  };
}
