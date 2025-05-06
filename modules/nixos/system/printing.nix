{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    attrValues
    ;
  inherit (lib.types) listOf str;

  cfg = config.garden.system.printing;
in
{
  options.garden.system.printing = {
    enable = mkEnableOption "printing";

    extraDrivers = mkOption {
      type = listOf str;
      default = [ ];
      description = "A list of additional drivers to install for printing";
    };
  };

  config = mkIf cfg.enable {
    # enable cups and some drivers for common printers
    services = {
      printing = {
        enable = true;

        drivers = attrValues {
          inherit (pkgs) gutenprint hplip;

          inherit (cfg) extraDrivers;
        };
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
