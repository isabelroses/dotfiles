{ config, ... }:
{
  # pulseaudio backup
  services.pulseaudio.enable = !config.services.pipewire.enable;
}
