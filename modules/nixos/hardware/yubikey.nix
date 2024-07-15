{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.types) nullOr enum;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  options.garden.system.yubikeySupport = {
    enable = mkEnableOption "yubikey support";

    deviceType = mkOption {
      type = nullOr (enum [
        "NFC5"
        "nano"
      ]);
      default = null;
      description = "A list of devices to enable Yubikey support for";
    };
  };

  config = mkIf config.garden.system.yubikeySupport.enable {
    hardware.gpgSmartcards.enable = true;

    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # Yubico's official tools
      yubikey-manager # cli
      yubikey-manager-qt # gui
      yubikey-personalization # cli
      yubikey-personalization-gui # gui
      yubico-piv-tool # cli
      yubioath-flutter # gui
    ];
  };
}
