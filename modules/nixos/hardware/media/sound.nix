{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) isx86Linux;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
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
        # <https://docs.pipewire.org/page_man_pipewire_conf_5.html>
        "10-defaults" = {
          "context.properties" = {
            "core.daemon" = true;
            "settings.check-quantum" = true;
          };
        };

        "10-loopback" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
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
              };
            }
          ];
        };

        "90-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 32;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 32;
          };
        };
      };

      wireplumber.extraConfig = {
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.a2dp.ldac.quality" = "hq";
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
              "hfp_hf"
              "hfp_ag"
              "hsp_hs"
              "hsp_ag"
            ];
          };
        };
      };
    };
  };
}
