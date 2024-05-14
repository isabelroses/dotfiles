{ config, ... }:
let
  inherit (config.modules) device;
in
{
  # remove stupid sites that i just don't want to see
  networking.stevenblack = {
    enable = device.type != "server";
    block = [
      "fakenews"
      "gambling"
    ];
  };
}
