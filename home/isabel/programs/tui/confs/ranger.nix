{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
with lib; let
  inherit (osConfig.modules) programs device;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (programs.tui.enable)) {
    home.packages = with pkgs; [
      ranger
    ];

    # TODO: more file preview methods
    xdg.configFile."ranger/rc.conf".text = ''
      set preview_images true
      ${(optionalString config.programs.kitty.enable "set preview_images_method kitty")}
    '';
  };
}
