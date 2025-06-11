{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.garden.profiles.workstation.enable {
    garden.packages = {
      inherit (pkgs) lix-diff;
    };
  };
}
