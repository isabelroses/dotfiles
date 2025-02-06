{
  lib,
  self,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isAcceptedDevice;
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
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && config.garden.programs.tui.enable) {
    home.packages = [ pkgs.ranger ];

    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      ${optionalString config.programs.kitty.enable "set preview_images_method kitty"}
    '';
  };
}
