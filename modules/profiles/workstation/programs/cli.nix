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
      # home-manager is so strange and needs these declared muliple times
      fish.enable = true;

      # type "fuck" to fix the last command that made you go "fuck"
      thefuck.enable = true;

      # help manage android devices via command line
      adb.enable = true;

      # direnv is cool
      direnv = {
        enable = true;
        silent = true;

        # faster, persistent
        nix-direnv.enable = true;
      };
    };

    # determine which version of wine to use
    environment.systemPackages = with pkgs; let
      winePackage =
        if (env.isWayland)
        then wineWowPackages.waylandFull
        else wineWowPackages.stableFull;
    in [winePackage];
  };
}
