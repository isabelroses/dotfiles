{ config, ... }:
let
  inherit (config.modules) environment;
in
{
  services.displayManager.sddm = {
    enable = environment.loginManager == "sddm";
    wayland.enable = true;
    settings.General.InputMethod = "";
  };
}
