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
    # able to change scheduling policies, e.g. to SCHED_RR
    security.rtkit.enable = lib.mkForce config.services.pipewire.enable;

    # no thanks lol
    services.pulseaudio.enable = lib.mkForce false;

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

      extraLadspaPackages = [ pkgs.rnnoise-plugin ];

      extraConfig.pipewire = {
        "10-loopback" = {
          "context.modules" = [
            {
              "node.description" = "playback loop";
              "audio.position" = [
                "FL"
                "FR"
              ];

              "capture.props" = {
                "node.name" = "playback_sink";
                "node.description" = "playback-sink";
                "media.class" = "Audio/Sink";
              };

              "playback.props" = {
                "node.name" = "playback_sink.output";
                "node.description" = "playback-sink-output";
                "media.class" = "Audio/Source";
                "node.passive" = true;
              };
            }
          ];
        };
      };
    };

    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
}
