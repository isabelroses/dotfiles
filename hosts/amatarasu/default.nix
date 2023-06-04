{ config, lib, pkgs, ... }:

let
  system = import ../../users/isabel/env.nix;
in {
  imports = [
      ../common
      ../common/settings.nix
      ../../users/isabel

      ./hardware-configuration.nix

      ./services.nix
      ./ui.nix
      ./packages.nix
      ./networking.nix
    ];
  # nixpkgs.overlays = [(import ../../users/${system.currentUser}/overlays)];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.efiSysMountPoint = "/boot/efi";
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
  };
}
