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
      socat
      jaq
      acpi
      upower
      inotify-tools
      blueberry
      networkmanagerapplet
      gnome.gnome-bluetooth
      gtk3
      pango
      cairo
      harfbuzz
      gdk-pixbuf
      glib
      nur.repos.bella.gjs # patched gjs version
    ];

    programs.eww = {
      enable = true;
      package = ewwPackage;
      configDir = ./config;
    };
  };
}
