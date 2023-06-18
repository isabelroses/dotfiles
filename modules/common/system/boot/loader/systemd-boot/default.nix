{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf;

  cfg = config.modules.system;
in {
  config = mkIf (cfg.boot.loader == "systemd-boot") {
    boot.loader = {
      systemd-boot = {
        enable = mkDefault true;
        configurationLimit = null;
        consoleMode = "max"; # the default is "keep", can be overriden per host if need be

        # Fix a security hole in place for backwards compatibility. See desc in
        # nixpkgs/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
        editor = false;
      };
    };
  };
}
