{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  device = config.modules.device;
in {
  imports = [inputs.nix-ld.nixosModules.nix-ld];

  config = mkIf (device.type != "server") {
    environment.systemPackages = [pkgs.appimage-run];

    # run appimages with appimage-run
    boot.binfmt.registrations = lib.genAttrs ["appimage" "AppImage"] (ext: {
      recognitionType = "extension";
      magicOrExtension = ext;
      interpreter = "/run/current-system/sw/bin/appimage-run";
    });

    # run unpatched linux binaries with nix-ld
    programs.nix-ld.dev = {
      enable = false;
      libraries = with pkgs; [
        openssl
        curl
        glib
        gjs
        util-linux
        glibc
        libnotify
        gdk-pixbuf
      ];
    };
  };
}
