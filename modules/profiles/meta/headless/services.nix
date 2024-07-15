{ lib, ... }:
{
  # a headless system should not mount any removable media
  # without explicit user action
  services.udisks2.enable = lib.modules.mkForce false;
}
