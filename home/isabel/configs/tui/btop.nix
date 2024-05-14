{ lib, osConfig, ... }:
let
  acceptedTypes = [
    "desktop"
    "laptop"
    "wsl"
    "lite"
    "hybrid"
  ];
in
{
  config =
    lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.tui.enable)
      {
        programs.btop = {
          enable = true;
          settings = {
            vim_keys = true;
            rounded_corners = true;
          };
        };
      };
}
