{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
in
{
  # compress half of the ram to use as swap
  # basically, get more memory per memory
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90; # defaults to 50
  };

  boot.kernel.sysctl = mkIf config.zramSwap.enable {
    # zram is relatively cheap, prefer swap
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    # zram is in memory, no need to readahead
    "vm.page-cluster" = 0;
  };
}
