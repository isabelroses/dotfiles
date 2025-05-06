{ config, ... }:
{
  config.services.pipewire.wireplumber.enable = config.services.pipewire.enable;
}
