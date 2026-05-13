{ lib, ... }:
let
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.profiles = {
    graphical.enable = mkEnableOption "Graphical interface";
    headless.enable = mkEnableOption "Headless";
    workstation.enable = mkEnableOption "Workstation";
    laptop.enable = mkEnableOption "Laptop";
    server.enable = mkEnableOption "Server";
  };
}
