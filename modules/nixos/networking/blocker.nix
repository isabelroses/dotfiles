{ config, ... }:
{
  # remove stupid sites that i just don't want to see
  networking.stevenblack = {
    enable = !config.garden.profiles.server.enable;
    block = [
      "fakenews"
      "gambling"
      "porn"
      # "social"
    ];
  };
}
