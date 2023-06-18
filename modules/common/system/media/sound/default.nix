{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.system.sound;
  device = config.modules.device;
in {
  config = mkIf (cfg.enable && device.hasSound) {
    # enable sound support and media keys if device has sound
    sound = {
      enable = true;
      mediaKeys.enable = true;
    };
    # able to change scheduling policies, e.g. to SCHED_RR
    security.rtkit.enable = true;

    # we replace pulseaudio with the incredibly based pipewire
    services.pipewire = {
      enable = mkDefault true;
      alsa = {
        enable = true;
        support32Bit = true; # TODO: make this only enable on 32bit systems
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # if for some reason pipewire is disabled, we may enable pulseaudio as backup
    # I don't like PA, but I won't discard it altogether
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
