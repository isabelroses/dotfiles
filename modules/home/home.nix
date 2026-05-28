{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  home = {
    stateVersion = osConfig.garden.system.stateVersion;

    # WARNING: this is an experimental option added by my fork of home-manager
    linker.backend = "smfh";
  };

  # reload system units when changing configs
  systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
}
