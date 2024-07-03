{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  imports = [
    ./pipewire
    ./wireplum

    ./misc.nix
    ./pulseaudio.nix
    ./realtime.nix
    ./rtkit.nix
  ];

  options.garden = {
    device.hasSound = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the system has sound support (usually true except for servers)";
    };

    system.sound.enable = mkEnableOption "Does the device have sound and its related programs be enabled";
  };
}
