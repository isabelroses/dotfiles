{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  cfg = config.garden.programs.cocogitto;
in
{
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
