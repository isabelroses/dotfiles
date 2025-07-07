{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config =
    mkIf
      (config.garden.profiles.graphical.enable && config.garden.programs.defaults.browser == "zen-browser")
      {
        programs.zen-browser = {
          enable = lib.mkDefault true;
          policies = {
            DisableAppUpdate = true;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
          };
        };
        programs.zen-browser.nativeMessagingHosts = [ pkgs.firefoxpwa ];
      };
}
