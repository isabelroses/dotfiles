{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;

  acceptedTypes = [
    "laptop"
    "desktop"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && osConfig.garden.programs.gui.enable) {
    home.packages = with pkgs; [ viewnior ];

    xdg.configFile."viewnior/viewnior.conf".text = ''
      [prefs]
      zoom-mode=0
      fit-on-fullscreen=true
      show-hidden=true
      dark-background=false
      smooth-images=true
      confirm-delete=true
      reload-on-save=false
      show-menu-bar=false
      show-toolbar=false
      show-scrollbar=false
      show-statusbar=false
      start-maximized=false
      slideshow-timeout=5
      auto-resize=false
      behavior-wheel=1
      behavior-click=0
      behavior-modify=0
      jpeg-quality=100
      png-compression=9
      desktop=6
    '';
  };
}
