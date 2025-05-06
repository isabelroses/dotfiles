{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge genAttrs;

  services = [
    "login"
    "greetd"
    "tuigreet"
  ];

  mkService = {
    enableGnomeKeyring = true;
    gnupg = {
      enable = true;
      noAutostart = true;
      storeOnly = true;
    };
  };
in
{
  security.pam = mkMerge [
    {
      # fix "too many files open" errors while writing a lot of data at once
      # was previously a huge issue when rebuilding
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];

      # allow screen lockers to also unlock the screen
      # (e.g. swaylock, gtklock)
      services = {
        swaylock.text = "auth include login";
        gtklock.text = "auth include login";
      };
    }

    (mkIf config.garden.profiles.graphical.enable {
      services = genAttrs services (_: mkService);
    })
  ];
}
