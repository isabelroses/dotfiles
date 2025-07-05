{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # use networkmanager in the live environment
  networking.networkmanager = {
    enable = true;
    # we don't want any plugins, they only takeup space
    # you might consider adding some if you need a VPN for example
    plugins = [ ];
  };

  networking.wireless.enable = mkForce false;

  # allow ssh into the system for headless installs
  systemd.services.sshd.wantedBy = mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
  ];
}
