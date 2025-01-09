{ lib, ... }:
let
  inherit (lib.attrsets) genAttrs;
in
{
  # unlock GPG keyring on login
  security.pam.services =
    genAttrs
      [
        "login"
        "greetd"
        "tuigreet"
      ]
      (_: {
        enableGnomeKeyring = true;
        gnupg = {
          enable = true;
          noAutostart = true;
          storeOnly = true;
        };
      });
}
