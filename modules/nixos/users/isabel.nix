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
    };
  };
}
