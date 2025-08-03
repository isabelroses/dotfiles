{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  programs.zed-editor =
    mkIf (config.garden.profiles.graphical.enable && config.garden.profiles.workstation.enable)
      {
        enable = true;
      };
}
