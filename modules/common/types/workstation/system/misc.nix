{
  config,
  lib,
  ...
}: let
  inherit (config.modules) device;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = lib.mkIf (builtins.elem device.type acceptedTypes) {
    # enable polkit for privilege escalation
    security.polkit.enable = true;

    # enable the unified cgroup hierarchy (cgroupsv2)
    systemd.enableUnifiedCgroupHierarchy = true;
  };
}
