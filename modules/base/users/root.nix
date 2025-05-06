{ lib, _class, ... }:
{
  users.users.root = lib.mkIf (_class == "nixos") {
    initialPassword = "changeme";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
    ];
  };
}
