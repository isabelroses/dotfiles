let
  common = {
    enableGnomeKeyring = true;
    gnupg = {
      enable = true;
      noAutostart = true;
      storeOnly = true;
    };
  };
in
{
  # unlock GPG keyring on login
  security.pam.services = {
    login = common;
    greetd = common;
    tuigreet = common;
  };
}
