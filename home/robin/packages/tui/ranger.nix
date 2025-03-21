{
  lib,
  pkgs,
  self,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
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
  config = mkIf (hasProfile osConfig acceptedTypes && config.garden.programs.tui.enable) {
    home.packages = [ pkgs.ranger ];

    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      ${optionalString config.programs.kitty.enable "set preview_images_method kitty"}
    '';
  };
}
