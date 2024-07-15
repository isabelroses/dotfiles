{ lib, ... }:
{
  # enable the unified cgroup hierarchy (cgroupsv2)
  systemd.enableUnifiedCgroupHierarchy = lib.modules.mkForce true;
}
