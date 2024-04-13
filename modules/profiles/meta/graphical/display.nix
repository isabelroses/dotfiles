{config, ...}: let
  inherit (config.modules) environment;
in {
  services.displayManager.sddm = {
    enable = environment.loginManager == "sddm";
    wayland.enable = true;
    # theme = pkgs.catppuccin-sddm;
    settings.General.InputMethod = "";
  };
}
