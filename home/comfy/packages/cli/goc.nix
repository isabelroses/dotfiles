{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;
  cfg = osConfig.garden.programs.cocogitto;
in
{
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
