{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.types) raw;
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkOverride;

  cfg = config.garden.system.kernel;
in
{
  options.garden.system.kernel = {
    packages = mkOption {
      type = raw;
      default = pkgs.linuxPackages_latest;
      defaultText = "pkgs.linuxPackages_latest";
      description = "The kernel to use for the system.";
    };
  };

  config = {
    # we set the kernel to be defaulted to the one set by our settings
    # we happen to default this to the latest kernel sooo:
    # always use the latest kernel, love the unstablity
    boot.kernelPackages = mkOverride 500 cfg.packages;
  };
}
