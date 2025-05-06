{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.garden.system.yubikeySupport = {
    enable = mkEnableOption "yubikey support";
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

    # Yubico's official tools
    garden.packages = {
      inherit (pkgs)
        yubikey-manager # cli
        # yubikey-manager-qt # gui
        ;
    };
  };
}
