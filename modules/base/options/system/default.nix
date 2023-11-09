{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption optionals types;
in {
  imports = [
    ./networking

    ./activation.nix
    ./boot.nix
    ./emulation.nix
    ./encryption.nix
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
      description = ''
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
      description = ''
        Whether to enable passwordless login. This is generally useful on systems with
        FDE (Full Disk Encryption) enabled. It is a security risk for systems without FDE.
      '';
    };

    fs = mkOption {
      type = with types; listOf str;
      default = ["vfat" "ext4"];
      description = ''
        A list of filesystems available supported by the system
        it will enable services based on what strings are found in the list.

        It would be a good idea to keep vfat and ext4 so you can mount USBs.
      '';
    };

    flakePath = mkOption {
      type = types.str;
      default = "/home/isabel/.config/flake";
      description = "The path to the configuration";
    };

    yubikeySupport = {
      enable = mkEnableOption "yubikey support";
      deviceType = mkOption {
        type = with types; nullOr enum ["NFC5" "nano"];
        default = null;
        description = "A list of devices to enable Yubikey support for";
      };
    };

    sound = {
      enable = mkEnableOption "sound";
      description = "Does the device have sound and its related programs be enabled";
    };

    video = {
      enable = mkEnableOption "video drivers";
      description = "Does the device allow for graphical programs";
    };

    bluetooth = {
      enable = mkEnableOption "bluetooth";
      description = "should the device load bluetooth drivers and enable blueman";
    };
  };
}
