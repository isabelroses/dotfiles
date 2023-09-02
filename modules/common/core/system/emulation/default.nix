{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  sys = config.modules.system;
in {
  config = mkIf sys.emulation.enable {
    nix.settings.extra-sandbox-paths = ["/run/binfmt" "${pkgs.qemu}"];

    boot.binfmt = {
      emulatedSystems = sys.emulation.systems;
      registrations = {
        # aarch64 interpreter
        aarch64-linux = {
          interpreter = lib.mkForce "${pkgs.qemu}/bin/qemu-aarch64";
        };

        # i686 interpreter
        i686-linux = {
          interpreter = "${pkgs.qemu}/bin/qemu-i686";
        };

        # x86_64
        x86_64-linux = {
          interpreter = "${pkgs.qemu}/bin/qemu-x86_64";
        };
      };
    };
  };
}
