{ lib, config, ... }:
{
  time = {
    timeZone = lib.mkDefault (if config.garden.profiles.server.enable then "UTC" else "Europe/London");
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = lib.mkDefault "en_GB.UTF-8";

    extraLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };
}
