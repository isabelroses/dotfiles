{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.system.emulation = {
    # should we enable emulation for additional architechtures?
    # enabling this option will make it so that you can build for, e.g.
    # aarch64 on x86_&4 and vice verse - not recommended on weaker machines
    enable = mkEnableOption ''
      emulation of additional arcitechtures via binfmt. enabling this option will make it so that the system can build for
      addiitonal systems such as aarc64 on x86_64 and vice versa.
    '';

    systems = mkOption {
      type = with types; listOf str;
      default = builtins.filter (system: system != pkgs.system) ["aarch64-linux" "i686-linux"];
      description = ''
        the systems to enable emulation for
      '';
    };
  };
}
