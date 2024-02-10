{
  config,
  lib,
  ...
}: let
  inherit (config.modules) device;
  inherit (lib) mkForce mkIf;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    # enable polkit for privilege escalation
    security.polkit.enable = true;

    # enable the unified cgroup hierarchy (cgroupsv2)
    systemd.enableUnifiedCgroupHierarchy = mkForce true;
  };
}
