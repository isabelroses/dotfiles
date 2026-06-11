{ config, ... }:
{
  security = {
    polkit = {
      enable = true;

      # i use run0; which basically makes this useless unless a package
      # actually needs it
      enablePkexecWrapper = false;
    };

    # this should only be installed on graphical systems
    soteria.enable = config.garden.profiles.graphical.enable;
  };
}
