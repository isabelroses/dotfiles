{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) device;
in {
  config = mkIf (device.type != "server") {
    environment.systemPackages = [pkgs.appimage-run];

    # run appimages with appimage-run
    boot.binfmt.registrations = lib.genAttrs ["appimage" "AppImage"] (ext: {
      recognitionType = "extension";
      magicOrExtension = ext;
      interpreter = "/run/current-system/sw/bin/appimage-run";
    });

    # run unpatched linux binaries with nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        openssl
        curl
        glib
        util-linux
        glibc
        icu
        libunwind
        libuuid
        zlib
        libsecret
        # graphical
        freetype
        libglvnd
        libnotify
        SDL2
        vulkan-loader
        gdk-pixbuf
        xorg.libX11
      ];
    };
  };
}
