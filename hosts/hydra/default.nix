{ config, lib, pkgs, ... }:

let
  system = import ../../users/isabel/env.nix;
in {
  imports = [
      ../common
      ../common/settings.nix
      ../common/ui.nix
      ../../users/isabel

      ./hardware-configuration.nix

      ./services.nix
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
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
    kernel.sysctl = {
      "vm.swappiness" = 50;
      "vm.max_map_count" = 2147483642;
    };
  };
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;

    pam.loginLimits = [
      # Unlimited amount of processes for root
      {
        domain = "root";
        item = "nproc";
        value = "unlimited";
      }
      # Unlimited open file descriptors
      {
        domain = "*";
        item = "nofile";
        value = "unlimited";
      }
    ];
  };
}
