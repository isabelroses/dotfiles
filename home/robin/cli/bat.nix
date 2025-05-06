{ config, ... }:
let
  inherit (config.garden.programs) defaults;
in
{
  programs.bat = {
    inherit (config.garden.profiles.workstation) enable;

    config = {
      inherit (defaults) pager;
      color = "always";
      style = "changes";
    };
  };
}
