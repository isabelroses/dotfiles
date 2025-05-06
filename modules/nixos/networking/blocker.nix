{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  # remove stupid sites that i just don't want to see
  config = mkIf (!config.garden.profiles.server.enable) {
    networking.stevenblack = {
      enable = true;
      block = [
        "fakenews"
        "gambling"
        "porn"
        # "social"
      ];
    };
  };
}
