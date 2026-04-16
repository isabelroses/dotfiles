{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf genAttrs;

  cfg = config.garden.system.security.binaries;
in
{
  options.garden.system.security = {
    binaries.enable = lib.mkEnableOption "allow for none patched binaries to be run";
  };

  config = mkIf cfg.enable {
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
          sdl3
          vulkan-loader
          gdk-pixbuf
          libx11
          ;

        inherit (pkgs.stdenv.cc) cc;
      };
    };
  };
}
