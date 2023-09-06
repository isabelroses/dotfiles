{
  config,
  lib,
  pkgs,
  ...
}: let
  sys = config.modules.system;
in {
  config = lib.mkIf sys.printing.enable {
    # enable cups and add some drivers for common printers
    services = {
      printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          hplip
        ];
      };

      # required for network discovery of printers
      avahi = {
        enable = true;
        # resolve .local domains for printers
        nssmdns = true;
        # pass avahi port(s) to the firewall
        openFirewall = true;
      };
    };
  };
}
