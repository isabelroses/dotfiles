{
  lib,
  config,
  pkgs,
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
      enable = true;
      mediaKeys.enable = true;
    };

    # able to change scheduling policies, e.g. to SCHED_RR
    security.rtkit.enable = config.services.pipewire.enable;

    # pipewire is newer and just better
    services.pipewire = {
      enable = mkDefault true;
      wireplumber.enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = isx86Linux pkgs;
      };

      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
    };

    # pulseaudio backup
    hardware.pulseaudio.enable = !config.services.pipewire.enable;
    # write bluetooth rules if and only if pipewire is enabled AND the device has bluetooth
    environment.etc = mkIf (config.services.pipewire.enable && device.hasBluetooth) {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };
    systemd.user.services = {
      pipewire.wantedBy = ["default.target"];
      pipewire-pulse.wantedBy = ["default.target"];
    };
  };
}
