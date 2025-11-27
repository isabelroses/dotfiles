{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.garden.profiles.graphical.enable {
    services.mullvad-vpn.enable = true;

    garden.packages = {
      inherit (pkgs) mullvad-vpn;
    };
  };
}
