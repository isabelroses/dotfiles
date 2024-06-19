{ config, ... }:
{
  imports = [ ./settings.nix ];

  config.services.pipewire.wireplumber.enable = config.services.pipewire.enable;
}
