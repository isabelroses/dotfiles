{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf;

  cfg = config.modules.system;
in {
  config = mkIf (cfg.boot.loader == "grub") {
    boot.loader = {
      # default grub to disabled, we manually enable grub on "server" hosts
      # or any other host that needs it
      grub = {
        enable = mkDefault false;
        useOSProber = true;
        efiSupport = true;
        enableCryptodisk = mkDefault false;
        device = "nodev";
        theme = null;
        backgroundColor = null;
        splashImage = null;
      };
    };
  };
}
