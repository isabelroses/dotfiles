{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.garden.profiles.upcloud = {
    enable = mkEnableOption "UpCloud profile";
  };

  config = mkIf config.garden.profiles.upcloud.enable {
    garden = {
      device = {
        cpu = "intel";
        gpu = "intel";
      };

      system.boot = {
        loader = "grub";
        grub.device = "/dev/vda";
      };
    };
  };
}
