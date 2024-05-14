{ lib, ... }:
{
  # enable the unified cgroup hierarchy (cgroupsv2)
  systemd.enableUnifiedCgroupHierarchy = lib.mkForce true;
}
