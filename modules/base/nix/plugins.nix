{
  lib,
  config,
  inputs',
  ...
}:
{
  config = lib.mkIf config.garden.profiles.workstation.enable {
    garden.packages = {
      inherit (inputs'.tgirlpkgs.packages) lix-diff;
    };
  };
}
