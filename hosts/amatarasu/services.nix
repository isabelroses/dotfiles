{
  config,
  lib,
  pkgs,
  ...
}:
let 
  system = import ../../users/isabel/env.nix;
in {
  services = {
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