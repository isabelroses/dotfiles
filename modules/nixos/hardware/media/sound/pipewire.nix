{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) isx86Linux;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
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

      configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-loopback.conf" ''
          context.modules = [
          {   name = libpipewire-module-loopback
              args = {
                node.description = "playback loop"
                audio.position = [ FL FR ]
                capture.props = {
                    node.name = playback_sink
                    node.description = "playback-sink"
                    media.class = "Audio/Sink"
                }
                playback.props = {
                    node.name = "playback_sink.output"
                    node.description = "playback-sink-output"
                    media.class = "Audio/Source"
                    node.passive = true
                }
              }
          }
          ]
        '')
      ];
    };

    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
}
