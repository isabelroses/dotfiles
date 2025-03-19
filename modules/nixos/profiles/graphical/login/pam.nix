{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;

  inherit (lib.attrsets) genAttrs;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
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
  };
}
