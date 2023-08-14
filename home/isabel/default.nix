{
  inputs,
  config,
  lib,
  self,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [
    # imported home-manager modules
    inputs.catppuccin.homeManagerModules.catppuccin
    self.homeManagerModules.gtklock

    # important system level configurations
    ./system

    # programs sets
    ./programs

    # system services, organized by display protocol
    ./services

    # declarative system and program themes (qt/gtk)
    ./themes

    # dev shells
    ./shells

    # other settings that can't be organized as easly
    ./misc
  ];
  config = {
    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

    home = {
      username = "isabel";
      homeDirectory = "/home/isabel";
      extraOutputsToInstall = ["doc" "devdoc"];

      stateVersion = mkDefault "23.05";
    };

    manual = {
      # the docs suck, so we disable them to save space
      html.enable = false;
      json.enable = false;
      manpages.enable = false;
    };

    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;
  };
}
