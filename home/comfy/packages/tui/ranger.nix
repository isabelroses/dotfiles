{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;
  inherit (lib.strings) optionalString;

  acceptedTypes = [
    "desktop"
    "laptop"
    "wsl"
    "lite"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && osConfig.garden.programs.tui.enable) {
    home.packages = [ pkgs.ranger ];

    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      ${optionalString config.programs.kitty.enable "set preview_images_method kitty"}
    '';
  };
}
