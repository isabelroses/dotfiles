{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption optionals types;
in {
  imports = [
    ./activation.nix
    ./boot.nix
    ./emulation.nix
    ./encryption.nix
    ./networking.nix
    ./printing.nix
    ./security.nix
    ./virtualization.nix
  ];

  options.modules.system = {
    warnings = optionals (config.modules.system.users == []) [
      ''
        You have not added any users to be supported by your system. You may end up with an unbootable system!
        Consider setting `config.modules.system.users` in your configuration
      ''
    ];

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

    autoLogin = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to enable passwordless login. This is generally useful on systems with
        FDE (Full Disk Encryption) enabled. It is a security risk for systems without FDE.
      '';
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
