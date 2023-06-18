{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  env = config.modules.usrEnv;
in {
  imports = [
    inputs.nh.nixosModules.default
  ];

  config = {
    # nh nix helper
    nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "daily";
      };
    };

    programs = {
      # home-manager is quirky as ever, and wants this to be set in system config
      # instead of just home-manager
      fish.enable = true;

      # type "fuck" to fix the last command that made you go "fuck"
      thefuck.enable = true;
    };
  };
}
