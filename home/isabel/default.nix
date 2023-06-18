{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [
    # external home-manager modules
    inputs.hyprland.homeManagerModules.default
    inputs.catppuccin.homeManagerModules.catppuccin

    # home package sets
    ./packages

    # apps and services I use
    ./apps # graphical apps
    ./services # system services, organized by display protocol

    # declarative system and program themes (qt/gtk)
    ./themes
  ];
  config = {
    catppuccin.flavour = "mocha";

    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

    home = {
      username = "isabel";
      homeDirectory = "/home/isabel";

      stateVersion = mkDefault "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];
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
