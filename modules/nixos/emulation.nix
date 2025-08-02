{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    splitString
    genAttrs
    flip
    pipe
    elemAt
    filter
    mkOption
    mkEnableOption
    ;
  inherit (lib.types)
    listOf
    str
    ;

  getArch = flip pipe [
    (splitString "-")
    (flip elemAt 0)
  ];

  cfg = config.garden.system.emulation;
in
{
  options.garden.system.emulation = {
    # should we enable emulation for additional architectures?
    # enabling this option will make it so that you can build for, e.g.
    # aarch64 on x86_&4 and vice verse - not recommended on weaker machines
    enable = mkEnableOption ''
      emulation of additional arcitechtures via binfmt. enabling this option will make it so that the system can build for
      additional systems such as aarc64 on x86_64 and vice versa.
    '';

    systems = mkOption {
      type = listOf str;
      default = filter (system: system != pkgs.stdenv.hostPlatform.system) [
        "x86_64-linux"
        "aarch64-linux"
        "i686-linux"
      ];
      description = ''
        the systems to enable emulation for
      '';
    };
  };

  config = mkIf cfg.enable {
    nix.settings.extra-sandbox-paths = [
      "/run/binfmt"
      (toString pkgs.qemu)
    ];

    boot.binfmt = {
      emulatedSystems = cfg.systems;

      # our archs that we want to emulate
      registrations = genAttrs cfg.systems (system: {
        interpreter = "${pkgs.qemu}/bin/qemu-${getArch system}";
      });
    };
  };
}
