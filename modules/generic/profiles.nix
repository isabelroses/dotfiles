{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.garden.profiles = {
    graphical.enable = mkEnableOption "Graphical interface";
    headless.enable = mkEnableOption "Headless";
    workstation.enable = mkEnableOption "Workstation";
    gaming.enable = mkEnableOption "Gaming";

    laptop.enable = mkEnableOption "Laptop";

    server = {
      enable = mkEnableOption "Server";

      # types of servers
      oracle.enable = mkEnableOption "Oracle";
      hetzner.enable = mkEnableOption "Hetzner";
    };
  };
}
