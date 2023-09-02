{
  config,
  lib,
  pkgs,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) isWayland;

  ewwPackage =
    if isWayland osConfig
    then pkgs.eww-wayland
    else pkgs.eww;

  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (isWayland osConfig) && osConfig.modules.usrEnv.programs.gui.enable && defaults.bar == "eww") {
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
