{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkBefore mkOptionDefault;
  inherit (lib.lists) singleton;

  mapOptionDefault = mapAttrs (_: mkOptionDefault);
in
{
  services.pipewire.extraConfig = {
    pipewire = {
      # Make PipeWire more verbose by default
      "10-logging" = {
        "context.properties"."log.level" = 3;
      };

      # <https://docs.pipewire.org/page_man_pipewire_conf_5.html>
      "10-defaults" = {
        "context.properties" = mapOptionDefault {
          "clock.power-of-two-quantum" = true;
          "core.daemon" = true;
          "core.name" = "pipewire-0";
          "link.max-buffers" = 16; # default is 64, is that really necessary?
          "settings.check-quantum" = true;
        };

        "context.spa-libs" = mapOptionDefault {
          "audio.convert.*" = "audioconvert/libspa-audioconvert";
          "avb.*" = "avb/libspa-avb";
          "api.alsa.*" = "alsa/libspa-alsa";
          "api.v4l2.*" = "v4l2/libspa-v4l2";
          "api.libcamera.*" = "libcamera/libspa-libcamera";
          "api.bluez5.*" = "bluez5/libspa-bluez5";
          "api.vulkan.*" = "vulkan/libspa-vulkan";
          "api.jack.*" = "jack/libspa-jack";
          "support.*" = "support/libspa-support";
          "video.convert.*" = "videoconvert/libspa-videoconvert";
        };
      };
    };

    pipewire-pulse = {
      # <https://docs.pipewire.org/page_man_pipewire-pulse_conf_5.html>
      "10-defaults" = {
        "context.spa-libs" = mapOptionDefault {
          "audio.convert.*" = "audioconvert/libspa-audioconvert";
          "support.*" = "support/libspa-support";
        };

        "pulse.cmd" = mkBefore [
          {
            cmd = "load-module";
            args = "module-always-sink";
            flags = [ ];
          }
        ];

        "pulse.properties" = {
          "server.address" = mkBefore [ "unix:native" ];
        };

        "pulse.rules" = mkBefore [
          {
            # skype does not want to use devices that don't have an S16 sample format.
            # we force the S16 format on the device to work around that
            matches = [
              { "application.process.binary" = "teams"; }
              { "application.process.binary" = "teams-insiders"; }
              { "application.process.binary" = "skypeforlinux"; }
            ];

            actions.quirks = [ "force-s16-info" ];
          }
          {
            # firefox marks the capture streams as don't move and then they
            # can't be moved with pwvucontrol or other tools.
            matches = singleton { "application.process.binary" = "firefox"; };
            actions.quirks = [ "remove-capture-dont-move" ];
          }
          {
            # speech dispatcher asks for too small latency and then underruns.
            matches = singleton { "application.name" = "~speech-dispatcher*"; };
            actions = {
              update-props = {
                "pulse.min.req" = "1024/48000"; # 21ms
                "pulse.min.quantum " = "1024/48000"; # 21ms
              };
            };
          }
        ];
      };
    };
  };
}
