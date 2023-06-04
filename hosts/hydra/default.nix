{ config, lib, pkgs, ... }:

let
  system = import ../../users/isabel/env.nix;
in {
  imports = [
      ../common
      ../../users/isabel

      ./hardware-configuration.nix

      ./services.nix
      ./ui.nix
      ./packages.nix
      ./networking.nix
    ];
  # nixpkgs.overlays = [(import ../../users/${system.currentUser}/overlays)];
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.utf8";
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
  virtualisation.docker.enable = true;
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
  };
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      cores = 4;
      max-jobs = "auto";
      sandbox = true;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  system = {
    stateVersion = "23.05";
    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-23.05";
    };
  };
}
