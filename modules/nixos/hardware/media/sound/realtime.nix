{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = config.garden.system.sound;
  dev = config.garden.device;
in
{
  config = mkIf (cfg.enable && dev.hasSound) {
    users = {
      users.${config.garden.system.mainUser}.extraGroups = [ "audio" ];
      groups.audio = { };
    };

    services.udev.extraRules = ''
      KERNEL=="cpu_dma_latency", GROUP="audio"
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';

    security.pam.loginLimits = [
      {
        domain = "@audio";
        type = "-";
        item = "rtprio";
        value = 99;
      }
      {
        domain = "@audio";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@audio";
        type = "-";
        item = "nice";
        value = -11;
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "soft";
        value = "99999";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "hard";
        value = "524288";
      }
    ];
  };
}
