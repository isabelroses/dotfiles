{ osConfig, ... }:
{
  home = {
    stateVersion = osConfig.garden.system.stateVersion;

    fileActivator = "putter";
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
}
