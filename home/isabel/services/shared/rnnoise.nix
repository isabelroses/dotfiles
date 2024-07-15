{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;

  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.isLinux) {
    xdg.configFile."pipewire/pipewire.conf.d/99-input-denoising.conf".text = builtins.toJSON {
      "context.modules" = [
        {
          "name" = "libpipewire-module-filter-chain";
          "args" = {
            "node.description" = "Noise Canceling source";
            "media.name" = "Noise Canceling source";
            "filter.graph" = {
              "nodes" = [
                {
                  "type" = "ladspa";
                  "name" = "rnnoise";
                  "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  "label" = "noise_suppressor_stereo";
                  "control" = {
                    "VAD Threshold (%)" = 30.0;
                  };
                }
              ];
            };
            "audio.position" = [
              "FL"
              "FR"
            ];
            "capture.props" = {
              "node.name" = "effect_input.rnnoise";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "effect_output.rnnoise";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}
