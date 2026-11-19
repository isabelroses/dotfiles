{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf config.garden.profiles.gaming.enable {
    garden.packages = { inherit (pkgs) prismlauncher amethyst-mod-manager; };

    programs = {
      steam = {
        enable = true;

        # proton-ge carries fixes (media codecs, game specific patches) that
        # valve's proton lacks, which a lot of unity titles like raft benefit from.
        # select it per game under properties -> compatibility
        extraCompatPackages = [ pkgs.proton-ge-bin ];

        gamescopeSession.enable = true;

        extraPackages = with pkgs; [
          at-spi2-atk
          fmodex
          fontconfig
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
          libunwind
          libvorbis
          libxcursor
          libxi
          libxinerama
          libxscrnsaver
          mono
          pango
          strace
          stdenv.cc.cc.lib
          zlib
        ];
      };

      gamescope = {
        enable = true;
        capSysNice = true;
      };

      gamemode = {
        enable = true;
        enableRenice = true;

        settings.general = {
          softrealtime = "auto";
          renice = 15;
        };
      };
    };
  };
}
