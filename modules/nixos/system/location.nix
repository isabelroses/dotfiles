{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    location.provider = "geoclue2";

    services.geoclue2 = {
      # enable geoclue2 only if location.provider is geoclue2
      enable = config.location.provider == "geoclue2";

      # TODO: make gammastep fall back to local if geoclue2 is disabled
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };
}
