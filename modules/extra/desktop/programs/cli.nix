{
  pkgs,
  config,
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

      # help manage android devices via command line
      adb.enable = true;
    };

    # determine which version of wine to be used
    # then add it to systemPackages
    environment.systemPackages = with pkgs; let
      winePackage =
        if (env.isWayland)
        then wineWowPackages.waylandFull
        else wineWowPackages.stableFull;
    in [winePackage];
  };
}
