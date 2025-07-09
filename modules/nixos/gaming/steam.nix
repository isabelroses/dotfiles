{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkOption mkEnableOption;

  cfg = config.garden.profiles.gaming.steam;
in
{
  options.garden.profiles.gaming.steam = {
    enable = mkEnableOption "Enable Steam" // {
      default = config.garden.profiles.gaming.enable;
    };

    gamescopeSession = {
      enable = mkEnableOption "gamescope TTY session" // {
        default = cfg.enable;
      };

      tty = mkOption {
        default = 4;
        type = lib.types.int;
        description = "tty to connect gamescope session on";
      };
    };
  };

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
      gamescopeSession.enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    garden.packages = {
      exec-gamescope = pkgs.writeShellApplication {
        name = "exec-gamescope";
        text = ''
          exec gamescope --adaptive-sync --rt --steam -- steam -pipewire-dmabuf -tenfoot
        '';
      };
    };

    environment.loginShellInit = mkIf cfg.gamescopeSession.enable ''
      [[ "$(tty)" = "/dev/tty${toString cfg.gamescopeSession.tty}" ]] && exec-gamescope
    '';

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
                  # keep-sorted start
                  at-spi2-atk
                  fmodex
                  gtk3
                  gtk3-x11
                  harfbuzz
                  icu
                  inetutils
                  keyutils
                  libgdiplus
                  libkrb5
                  libpng
                  libpulseaudio
                  libthai
                  libunwind # for titanfall 2 Northstar launcher
                  libvorbis
                  mono5
                  pango
                  strace
                  zlib
                  # keep-sorted end
                  ;

                inherit (pkgs.stdenv.cc.cc) lib;

                inherit (pkgs.xorg)
                  # keep-sorted start
                  libXScrnSaver
                  libXcursor
                  libXi
                  libXinerama
                  # keep-sorted end
                  ;
              };
          }
        );
      })
    ];
  };
}
