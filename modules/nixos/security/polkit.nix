{ config, ... }:
{
  security = {
    # have polkit log all actions
    polkit = {
      enable = true;

      # <https://github.com/NixOS/nixpkgs/pull/530106>
      enablePkexecWrapper = false;
    };

    # this should only be installed on graphical systems
    soteria.enable = config.garden.profiles.graphical.enable;
  };
}
