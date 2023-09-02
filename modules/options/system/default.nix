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
    ./emulation.nix
    ./printing.nix
  ];

  options.modules.system = {
    warnings =
      if config.modules.system.users == []
      then [
        ''
          You do not have a main user set. This may cause issues with some modules.
        ''
      ]
      else [];

    mainUser = mkOption {
      type = types.enum config.modules.system.users;
      description = "The username of the main user for your system";
      default = builtins.elemAt config.modules.system.users 0;
    };

    users = mkOption {
      type = with types; listOf str;
      default = ["isabel"];
      description = lib.mdDoc ''
        A list of users that you wish to declare as your non-system users. The first username
        in the list will be treated as your main user unless `modules.system.mainUser` is set.
      '';
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
      enable = mkEnableOption "video drivers";
    };

    # should the device load bluetooth drivers and enable blueman
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };
  };
}
