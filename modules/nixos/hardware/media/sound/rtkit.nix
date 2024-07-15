{ lib, config, ... }:
{
  # able to change scheduling policies, e.g. to SCHED_RR
  security.rtkit.enable = lib.modules.mkForce config.services.pipewire.enable;
}
