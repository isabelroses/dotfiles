{ pkgs, config, ... }:
{
  services.mullvad-vpn = {
    inherit (config.garden.profiles.graphical) enable;

    # this is not the default despite what you might think. this is the gui
    # version of the package
    package = pkgs.mullvad-vpn;

    # "Might have minor security impact, so consider disabling if you do not use the feature"
    # well i don't use it so. sure lets do that
    enableExcludeWrapper = false;
  };
}
