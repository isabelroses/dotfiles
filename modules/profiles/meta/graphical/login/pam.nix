{
  # unlock GPG keyring on login
  security.pam.services = let
    common = {
      enableGnomeKeyring = true;
      gnupg = {
        enable = true;
        noAutostart = true;
        storeOnly = true;
      };
    };
  in {
    login = common;

    greetd = common;

    tuigreet = common;
  };
}
