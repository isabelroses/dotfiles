{
  osConfig,
  lib,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (osConfig.modules.usrEnv.programs.tui.enable)) {
    programs.btop = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        # color_theme = "catppuccin_mocha";
        vim_keys = true;
        rounded_corners = true;
      };
    };
  };
}
