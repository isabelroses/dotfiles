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
              builtins.attrValues {
                extras = extraPkgs pkgs';

                inherit (pkgs')
                  # Add missing dependencies
                  libgdiplus
                  keyutils
                  libkrb5
                  libpng
                  libpulseaudio
                  libvorbis
                  at-spi2-atk
                  fmodex
                  gtk3
                  gtk3-x11
                  harfbuzz
                  icu
                  inetutils
                  libthai
                  mono5
                  pango
                  strace
                  zlib
                  libunwind # for titanfall 2 Northstart launcher
                  ;

                inherit (pkgs.stdenv.cc.cc) lib;

                inherit (pkgs.xorg)
                  libXcursor
                  libXi
                  libXinerama
                  libXScrnSaver
                  ;
              };
          }
        );
      })
    ];
  };
}
