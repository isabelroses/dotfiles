{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkDefault isx86Linux;
  inherit (config.modules) device;
  cfg = config.modules.system.sound;
in {
  imports = [inputs.nix-gaming.nixosModules.pipewireLowLatency];

  config = mkIf (cfg.enable && device.hasSound) {
    # enable sound support and media keys if device has sound
    sound = {
      enable = mkDefault false; # this just enables ALSA
      mediaKeys.enable = true;
    };

    # able to change scheduling policies, e.g. to SCHED_RR
    security.rtkit.enable = config.services.pipewire.enable;

    # pulseaudio backup
    hardware.pulseaudio.enable = !config.services.pipewire.enable;

    # pipewire is newer and just better
    services.pipewire = {
      enable = true;

      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };

      audio.enable = true;
      pulse.enable = true;
      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = isx86Linux pkgs;
      };

      wireplumber = {
        inherit (config.services.pipewire) enable;

        configPackages = lib.optionals device.hasBluetooth [
          (pkgs.writeTextDir "share/bluetooth.lua.d/51-bluez-config.lua" ''
            bluez_monitor.properties = {
              ["bluez5.enable-sbc-xq"] = true,
              ["bluez5.enable-msbc"] = true,
              ["bluez5.enable-hw-volume"] = true,
              ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
            }
          '')
        ];
      };
    };

    systemd.user.services = {
      pipewire.wantedBy = ["default.target"];
      pipewire-pulse.wantedBy = ["default.target"];
    };
  };
}
