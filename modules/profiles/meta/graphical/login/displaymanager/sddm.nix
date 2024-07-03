{ config, ... }:
let
  inherit (config.garden) environment;
in
{
  services.displayManager.sddm = {
    enable = environment.loginManager == "sddm";
    wayland.enable = true;
    settings.General.InputMethod = "";
  };
}
