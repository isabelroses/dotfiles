{ lib, config, ... }:
{
  time = {
    timeZone = lib.modules.mkDefault (
      if config.garden.profiles.server.enable then "UTC" else "Europe/London"
    );
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = lib.modules.mkDefault "en_GB.UTF-8";

    extraLocales = lib.modules.mkDefault [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };
}
