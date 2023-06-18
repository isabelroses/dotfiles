{
  config,
  lib,
  pkgs,
  osConfig,
  self,
  ...
}:
with lib; let
  ewwPackage =
    if env.isWayland
    then pkgs.eww-wayland
    else pkgs.eww;

  device = osConfig.modules.device;
  env = osConfig.modules.usrEnv;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
  mkService = lib.recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    home.packages = with pkgs; [
      ewwPackage
      socat
      jaq
      acpi
      wlsunset
      wl-gammactl
      upower
      inotify-tools
      blueberry
      gnome.gnome-bluetooth
      networkmanagerapplet
      gjs
      gtk3
      pango
      cairo
      harfbuzz
      gdk-pixbuf
      glib
    ];

    programs.eww = {
      enable = true;
      package = ewwPackage;
      configDir = ./config;
    };
  };
}
