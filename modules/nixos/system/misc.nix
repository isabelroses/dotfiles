{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    services = {
      # enable GVfs, a userspace virtual filesystem.
      gvfs.enable = true;

      # storage daemon required for udiskie auto-mount
      udisks2.enable = true;

      dbus = {
        enable = true;
        packages = builtins.attrValues { inherit (pkgs) gcr_4; };
      };
    };
  };
}
