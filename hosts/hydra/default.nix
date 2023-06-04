{ config, cloud, lib, pkgs, ... }:

let
  system = import ../../users/isabel/env.nix;
  cloud = import ../../env.nix;
in {
  imports = [
      ../common
      ../../users/isabel
      ./hardware-configuration.nix
    ];
  # nixpkgs.overlays = [(import ../../users/${system.currentUser}/overlays)];
  console = {
    font = "RobotoMono Nerd Font";
  };
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
  services = {
    avahi.nssmdns = true;
    flatpak.enable = true;
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    sshd.enable = true;
    gnome.gnome-keyring.enable = true;
  };
  programs = {
    chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      ];
    };
    gnupg.agent.enable = true;
  };
  services = {
    logind.extraConfig = ''
	HandleLidSwtich=ignore
	HandleLidSwitchDocked=ignore
	HandleLidSwitchExternalPower=ignore
    '';
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  systemd.services = {
    my_tunnel = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" "systemd-resolved.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloud.env}";
        Restart = "always";
        User = "${system.currentUser}";
        Group = "cloudflared";
      };
    };
    seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${lib.getExe pkgs.seatd} -g wheel";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
  virtualisation.docker.enable = true;
  networking = {
    networkmanager.enable = true;
    hostName = "hydra";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
  environment = {
    systemPackages = with pkgs; [
      git
      killall
      wget
      home-manager
      pipewire
      wireplumber 
      pulseaudio
    ];
  };
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
  };
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      cores = 4;
      max-jobs = "auto";
      sandbox = true;
      auto-optimise-store = true;
      substituters = [ "https://hyprland.cachix.org" "https://nix-community.cachix.org"];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = [ "RobotoMono" "JetBrainsMono" "CascadiaCode" "Hack" "Mononoki" "Ubuntu" "UbuntuMono" "Noto" ];})
  ];
  system = {
    stateVersion = "23.05";
    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-23.05";
    };
  };
}
