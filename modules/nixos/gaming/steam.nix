{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.programs.gaming;
in
{
  options.garden.programs.gaming.steam.enable = mkEnableOption "Enable Steam";

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      # Open ports in the firewall for Steam Remote Play
      # remotePlay.openFirewall = true;
      # Open ports in the firewall for Source Dedicated Server
      # dedicatedServer.openFirewall = true;
      # Compatibility tools to install
      # this option used to be provided by modules/shared/nixos/steam
      extraCompatPackages = [ pkgs.proton-ge-bin.steamcompattool ];
    };

    nixpkgs.overlays = [
      (_: prev: {
        steam = prev.steam.override (
          {
            extraPkgs ? _: [ ],
            ...
          }:
          {
            extraPkgs =
              pkgs':
              (extraPkgs pkgs')
              ++ (with pkgs'; [
                # Add missing dependencies
                libgdiplus
                keyutils
                libkrb5
                libpng
                libpulseaudio
                libvorbis
                stdenv.cc.cc.lib
                xorg.libXcursor
                xorg.libXi
                xorg.libXinerama
                xorg.libXScrnSaver
                at-spi2-atk
                fmodex
                gtk3
                gtk3-x11
                harfbuzz
                icu
                glxinfo
                inetutils
                libthai
                mono5
                pango
                stdenv.cc.cc.lib
                strace
                zlib
                libunwind # for titanfall 2 Northstart launcher
              ]);
          }
        );
      })
    ];
  };
}
