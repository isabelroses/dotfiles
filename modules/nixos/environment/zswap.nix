{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  # compress half of the ram to use as swap basically, get more memory per memory
  # <https://chrisdown.name/2026/03/24/zswap-vs-zram-when-to-use-what.html>
  boot.zswap = {
    enable = config.swapDevices != [ ];

    # defaults are good when its not a server
    maxPoolPercent = mkIf config.garden.profiles.server.enable 15;
  };
}
