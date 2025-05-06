{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf genAttrs;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    garden.packages = { inherit (pkgs) appimage-run; };

    # run appimages with appimage-run
    boot.binfmt.registrations =
      genAttrs
        [
          "appimage"
          "AppImage"
        ]
        (ext: {
          recognitionType = "extension";
          magicOrExtension = ext;
          interpreter = "/run/current-system/sw/bin/appimage-run";
        });

    # run unpatched linux binaries with nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = builtins.attrValues {
        inherit (pkgs)
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
          ;

        inherit (pkgs.stdenv.cc) cc;
        inherit (pkgs.xorg) libX11;
      };
    };
  };
}
