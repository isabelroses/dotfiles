{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
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
