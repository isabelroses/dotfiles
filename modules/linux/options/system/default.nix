{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption optionals types;
in {
  imports = [
    ./boot.nix
    ./emulation.nix
    ./encryption.nix
    ./networking.nix
    ./printing.nix
    ./security.nix
    ./virtualization.nix
  ];

  config.warnings = optionals (config.modules.system.fs == []) [
    ''
      You have not added any filesystems to be supported by your system. You may end up with an unbootable system!

      Consider setting {option}`config.modules.system.fs` in your configuration
    ''
  ];

  options.modules.system = {
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

    yubikeySupport = {
      enable = mkEnableOption "yubikey support";
      deviceType = mkOption {
        type = with types; nullOr (enum ["NFC5" "nano"]);
        default = null;
        description = "A list of devices to enable Yubikey support for";
      };
    };

    sound.enable = mkEnableOption "Does the device have sound and its related programs be enabled";
    video.enable = mkEnableOption "Does the device allow for graphical programs";
    bluetooth.enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
  };
}
