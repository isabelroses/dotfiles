{ lib, ... }:
let
  inherit (builtins) toString;
  inherit (lib.lists) singleton;
  inherit (lib.modules) mkForce;
in
{
  # Enable the threadirqs kernel parameter to reduce audio latency
  # See <https://github.com/musnix/musnix/blob/master/modules/base.nix#L56>
  boot.kernelParams = [ "threadirqs" ];

  services = {
    # configure PipeWire for low latency
    # the below configuration may not fit every use case
    # and you are recommended to experiment with the values
    # in order to find the perfect configuration
    pipewire =
      let
        # Higher audio rate equals less latency always, unless you
        # increase your quantum.
        # To calculate node latency for your audio device take the
        # quantum size divided by your audio rate
        # => 64/96000 = 0.00066666666 * 1000 = 0.6ms # this is 0.6ms node latency
        # To check client latency use `pw-top`, take the quantum size
        # and the audio rate of the client then use `quantum / audio rate * 1000`
        # to get overall latency for the client
        quantum = toString 64;
        rate = toString 48000;
        qr = "${quantum}/${rate}"; # quantum/rate
      in
      {
        # Additional configuration files that will be placed in /etc/pipewire/pipewire.conf.d/
        # with the given file name. According to the documentation, those files take JSON therefore
        # nixpkgs' toJSON should be suitable to write the configuration files via Nix expressions.
        # P.S. Using extraConfig already converts the expression to JSON, so toJSON is not necessary
        # Also see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#quantum-ranges>
        # Useful commands:
        #  pw-top                                            # see live stats
        #  journalctl -b0 --user -u pipewire                 # see logs (spa resync in "bad")
        #  pw-metadata -n settings 0                         # see current quantums
        #  pw-metadata -n settings 0 clock.force-quantum 128 # override quantum
        #  pw-metadata -n settings 0 clock.force-quantum 0   # disable override
        extraConfig = {
          pipewire."92-low-latency" = {
            "context.properties" = {
              "default.clock.rate" = rate;
              "default.clock.quantum" = quantum;
              "default.clock.min-quantum" = quantum;
              "default.clock.max-quantum" = quantum;
              "default.clock.allowed-rates" = [ rate ];
            };

            "context.modules" = [
              {
                name = "libpipewire-module-rtkit";
                flags = [
                  "ifexists"
                  "nofail"
                ];
                args = {
                  "nice.level" = -15;
                  "rt.prio" = 90;
                  "rt.time.soft" = 200000;
                  "rt.time.hard" = 200000;
                };
              }
              {
                name = "libpipewire-module-protocol-pulse";
                args = {
                  "server.address" = [ "unix:native" ];
                  "pulse.min.quantum" = qr;
                  "pulse.min.req" = qr;
                  "pulse.min.frag" = qr;
                };
              }
            ];

            "stream.properties" = {
              "node.latency" = qr;
              "resample.quality" = 1;
            };
          };

          pipewire-pulse."92-low-latency" = {
            "context.modules" = singleton {
              name = "libpipewire-module-protocol-pulse";
              args = {
                "pulse.min.req" = qr;
                "pulse.default.req" = qr;
                "pulse.max.req" = qr;
                "pulse.min.quantum" = qr;
                "pulse.max.quantum" = qr;
              };
            };

            "stream.properties" = {
              "node.latency" = qr;
              "resample.quality" = 4;
            };
          };
        };

        wireplumber = {
          enable = mkForce true;
          extraConfig = {
            # Configure each device/card/output to use the low latency configuration
            "92-low-latency" = {
              # Some applications still use the ALSA channels, so the configuration
              # for Wireplumber doesn't properly apply to them. In that case, they should
              # follow the ALSA configuration instead.
              "monitor.alsa.rules" = [
                {
                  matches = [
                    # Matches all devices.
                    { "device.name" = "~alsa_card.*"; }

                    # Matches all sinks.
                    { "node.name" = "~alsa_output.*"; }
                  ];

                  actions.update-props = {
                    # Give a human-readable name to the matching devices/sources/sinks.
                    "node.description" = "ALSA Low Latency Output";

                    # Low latency configuration
                    "audio.rate" = rate;
                    "audio.format" = "S32LE";
                    "resample.quality" = 4;
                    "resample.disable" = false;
                    # 0 disables suspend
                    "session.suspend-timeout-seconds" = 0;
                    "api.alsa.period-size" = 2;
                    # Default: 0
                    "api.alsa.headroom" = 128;
                    # Default: 2
                    "api.alsa.period-num" = 2;
                    # generally, USB soundcards use the batch mode
                    "api.alsa.disable-batch" = false;
                  };
                }
              ];
            };
          };
        };
      };
  };
}
