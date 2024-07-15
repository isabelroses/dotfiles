{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.hardware) isx86Linux;
  inherit (config.garden) device;
  cfg = config.garden.system.sound;
in
{
  imports = [
    ./settings.nix
    # ./low-latency.nix
  ];

  config = mkIf (cfg.enable && device.hasSound) {
    # pipewire is newer and just better
    services.pipewire = {
      enable = true;

      audio.enable = true;
      pulse.enable = true;
      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = isx86Linux pkgs;
      };
    };

    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
}
