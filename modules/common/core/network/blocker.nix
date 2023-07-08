{config, ...}: let
  device = config.modules.device;
in {
  # this should block *most* junk sites
  networking = {
    stevenblack = {
      enable = device.type != "server";
      block = [
        "fakenews"
        "gambling"
      ];
    };
  };
}
