{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.types) enum;
  inherit (lib.options) mkOption mkEnableOption;

  cfg = config.garden.system.security.selinux;
in
{
  options.garden.system.security.selinux = {
    enable = mkEnableOption "system SELinux support + kernel patches";
    state = mkOption {
      type = enum [
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
      type = enum [
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

  config = mkIf cfg.enable {
    # build systemd with SE Linux support so it loads policy at boot and supports file labelling
    systemd.package = pkgs.systemd.override { withSelinux = true; };

    # we cannot have apparmor and security together. disable apparmor
    security.apparmor.enable = mkForce false;

    boot = {
      # tell kernel to use SE Linux by adding necessary parameters
      kernelParams = [
        "security=selinux"
        "selinux=1"
      ];

      # compile kernel with SE Linux support
      # with additional support for other LSM modules
      kernelPatches = [
        {
          name = "selinux-config";
          patch = null;
          extraConfig = ''
            SECURITY_SELINUX y
            SECURITY_SELINUX_BOOTPARAM n
            SECURITY_SELINUX_DISABLE n
            SECURITY_SELINUX_DEVELOP y
            SECURITY_SELINUX_AVC_STATS y
            SECURITY_SELINUX_CHECKREQPROT_VALUE 0
            DEFAULT_SECURITY_SELINUX n
          '';
        }
      ];
    };

    environment = {
      systemPackages = with pkgs; [ policycoreutils ]; # for load_policy, fixfiles, setfiles, setsebool, semodile, and sestatus.

      # write selinux config to /etc/selinux
      etc."selinux/config".text = ''
        # This file controls the state of SELinux on the system.
        # SELINUX= can take one of these three values:
        #     enforcing - SELinux security policy is enforced.
        #     permissive - SELinux prints warnings instead of enforcing.
        #     disabled - No SELinux policy is loaded.
        SELINUX=${cfg.state}
        # SELINUXTYPE= can take one of three two values:
        #     targeted - Targeted processes are protected,
        #     minimum - Modification of targeted policy. Only selected processes are protected.
        #     mls - Multi Level Security protection.
        SELINUXTYPE=${cfg.type}
      '';
    };
  };
}
