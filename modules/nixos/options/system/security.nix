{ pkgs, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.modules.system.security = {
    fixWebcam = mkEnableOption "Fix the purposefully broken webcam by un-blacklisting the related kernel module.";
    tor.enable = mkEnableOption "Tor daemon";
    lockModules = mkEnableOption "Lock kernel modules to the ones specified in the configuration. Highly breaking.";

    selinux = {
      enable = mkEnableOption "system SELinux support + kernel patches";
      state = mkOption {
        type =
          with types;
          enum [
            "enforcing"
            "permissive"
            "disabled"
          ];
        default = "enforcing";
        description = ''
          SELinux state to boot with. The default is enforcing.
        '';
      };

      type = mkOption {
        type =
          with types;
          enum [
            "targeted"
            "minimum"
            "mls"
          ];
        default = "targeted";
        description = ''
          SELinux policy type to boot with. The default is targeted.
        '';
      };
    };

    auditd = {
      enable = mkEnableOption "Enable the audit daemon.";
      autoPrune = {
        enable = mkEnableOption "Enable auto-pruning of audit logs.";

        size = mkOption {
          type = types.int;
          default = 524288000; # roughly 500 megabytes
          description = "The maximum size of the audit log in bytes.";
        };

        dates = mkOption {
          type = types.str;
          default = "daily";
          example = "weekly";
          description = "How often cleaning is triggered. Passed to systemd.time";
        };
      };
    };
  };
}
