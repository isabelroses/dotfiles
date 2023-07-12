{
  config,
  lib,
  pkgs,
  osConfig,
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
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable && programs.default.bar == "eww") {
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
      gtk3
      gjs
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
