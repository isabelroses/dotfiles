{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  sys = config.modules.system;
in
{
  options.modules.system.emulation = {
    # should we enable emulation for additional architectures?
    # enabling this option will make it so that you can build for, e.g.
    # aarch64 on x86_&4 and vice verse - not recommended on weaker machines
    enable = mkEnableOption ''
      emulation of additional arcitechtures via binfmt. enabling this option will make it so that the system can build for
      additional systems such as aarc64 on x86_64 and vice versa.
    '';

    systems = mkOption {
      type = with types; listOf str;
      default = builtins.filter (system: system != pkgs.system) [
        "aarch64-linux"
        "i686-linux"
      ];
      description = ''
        the systems to enable emulation for
      '';
    };
  };

  config = mkIf sys.emulation.enable {
    nix.settings.extra-sandbox-paths = [
      "/run/binfmt"
      "${pkgs.qemu}"
    ];

    boot.binfmt = {
      emulatedSystems = sys.emulation.systems;

      # our archs that we want to emulate
      registrations = {
        aarch64-linux.interpreter = "${pkgs.qemu}/bin/qemu-aarch64";
        i686-linux.interpreter = "${pkgs.qemu}/bin/qemu-i686";
      };
    };
  };
}
