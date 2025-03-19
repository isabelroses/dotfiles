{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) environment;
in
{
  config = mkIf (environment.loginManager == "sddm") {
    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm; # allow qt6 themes to work
      wayland.enable = true; # run under wayland rather than X11
      settings.General.InputMethod = "";
    };
  };
}
