{
  lib,
  root,
  config,
  extpkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf config.garden.profiles.workstation.enable {
    sops.secrets.lethe-token = {
      sopsFile = root + /secrets/services/lethe.yaml;
      key = "token";
    };

    garden.packages = {
      inherit (extpkgs) lethe;
    };

    home.sessionVariables = {
      LETHE_SYNC_SERVER = "http://freyja:7374";
      LETHE_SYNC_TOKEN_FILE = config.sops.secrets.lethe-token.path;
    };
  };
}
