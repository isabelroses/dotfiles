{ osConfig, ... }:
{
  home = {
    stateVersion = osConfig.garden.system.stateVersion;

    # WARNING: this is an experimental option added by my fork of home-manager
    linker.backend = "smfh";
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
}
