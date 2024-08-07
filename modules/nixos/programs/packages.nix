{ pkgs, ... }:
{
  # packages that should be on all deviecs
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      git
      curl
      wget
      pciutils
      lshw
      ;
  };
}
