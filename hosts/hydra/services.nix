{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cloud = import ../../env.nix;
  system = import ../../users/isabel/env.nix;
in {
  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thunar thumbnail support for images

    # disable close laptop lid to sleep
    logind.extraConfig = ''
	HandleLidSwtich=ignore
	HandleLidSwitchDocked=ignore
	HandleLidSwitchExternalPower=ignore
    '';

    # audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    avahi.nssmdns = true;
    flatpak.enable = true; # enable flatpak support
    openssh = {
      enable = true;
      allowSFTP = true;
    };
    sshd.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  #systemd
  systemd.services = {
    tunnel = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" "systemd-resolved.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloud.env}";
        Restart = "always";
        User = "${system.currentUser}";
        Group = "cloudflared";
      };
    };

    # login manager
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
}
