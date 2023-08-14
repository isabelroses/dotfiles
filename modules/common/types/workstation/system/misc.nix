{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    # enable polkit for privilege escalation
    security.polkit.enable = true;

    # enable the unified cgroup hierarchy (cgroupsv2)
    systemd.enableUnifiedCgroupHierarchy = true;
  };
}
