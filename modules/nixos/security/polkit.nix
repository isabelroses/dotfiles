{ config, ... }:
{
  # have polkit log all actions
  security = {
    polkit.enable = true;

    # this should only be installed on graphical systems
    soteria.enable =
      config.garden.profiles.graphical.enable && !config.services.desktopManager.cosmic.enable;
  };
}
