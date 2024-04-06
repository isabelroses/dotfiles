{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "wsl" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.tui.enable) {
    home.packages = with pkgs; [
      ranger
    ];

    # TODO: more file preview methods
    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      ${(lib.optionalString config.programs.kitty.enable "set preview_images_method kitty")}
    '';
  };
}
