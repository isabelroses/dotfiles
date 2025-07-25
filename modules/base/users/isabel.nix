{
  lib,
  config,
  ...
}:
let
  inherit (lib) elem mkIf;
in
{
  config = mkIf (elem "isabel" config.garden.system.users) {
    users.users.isabel = {
      hashedPassword = "$y$j9T$vCF2V4znV5q3n6PxO5i6z/$T9Xw1s0PEvJys.29suA3Gbwv9XvJo98cZVhULWk0MtC";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
      ];
    };
  };
}
