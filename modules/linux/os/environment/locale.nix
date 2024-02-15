{lib, ...}: {
  time = {
    timeZone = "Europe/London";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_GB.utf8";

    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };
}
