{ config, ... }:
{
  services.mullvad-vpn = {
    inherit (config.garden.profiles.graphical) enable;

    # "Might have minor security impact, so consider disabling if you do not use the feature"
    # well i don't use it so. sure lets do that
    enableExcludeWrapper = false;

    gui.enable = true;
  };
}
