{ config, ... }:
{
  programs.noisetorch.enable =
    (config.services.pipewire.enable || config.services.pulseaudio.enable)
    && config.garden.profiles.graphical.enable;
}
