{ lib, pkgs, ... }:
{
  users.users.root = lib.modules.mkIf pkgs.stdenv.isLinux {
    initialPassword = "changeme";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
    ];
  };
}
