{ config, ... }:
{
  # pulseaudio backup
  hardware.pulseaudio.enable = !config.services.pipewire.enable;
}
