{
  lib,
  config,
  ...
}:
with lib; {
  imports = [
    ./activation.nix
    ./boot.nix
    ./networking.nix
    ./security.nix
    ./virtualization.nix
  ];

  options.modules.system = {
    # the default user (not users) you plan to use on a specific device
    # this will dictate the initial home-manager settings if home-manager is
    # enabled in usrenv
    users = mkOption {
      type = with types; listOf str;
      default = ["isabel"];
      description = "The users of your system";
    };

    mainUser = mkOption {
      type = types.enum config.modules.system.users;
      description = "The username of the main user for your system";
      default = builtins.elemAt config.modules.system.users 0;
    };

    hostname = mkOption {
      type = types.str;
      description = "The name of the device for the system";
    };

    # the path to the flake
    flakePath = mkOption {
      type = types.str;
      default = "/home/isabel/.setup";
      description = "The path to the configuration";
    };

    # should sound related programs and audio-dependent programs be enabled
    sound = {
      enable = mkEnableOption "sound";
    };

    # should the device enable graphical programs
    video = {
      enable = mkEnableOption "video";
    };

    # should the device load bluetooth drivers and enable blueman
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };

    # should the device enable printing module and try to load common printer modules
    # you might need to add more drivers to the printing module for your printer to work
    printing = {
      enable = mkEnableOption "printing";
    };
  };
}
