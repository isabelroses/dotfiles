{ pkgs, config, ... }:
let
  mkMyVicinaeExt = pkgs.callPackage ./extension.nix { };
in
{
  programs.vicinae = {
    enable = config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux;
    systemd.enable = true;

    settings = {
      window.opacity = 1;
    };

    # NOTE: I only do it this way because I hate IFD, normal people should use
    # `config.lib.vicinae.mkExtension`
    extensions = map mkMyVicinaeExt [
      {
        extName = "nix";
        npmDepsHash = "sha256-TEyCCDjAtRYX2uH2TpLfe4/hTzyfMiyDhzVdyQXhEus=";
      }
      {
        extName = "wifi-commander";
        npmDepsHash = "sha256-jwqICwIlJPRV3UdFBtA5ltjR8dImPFtsOqda1MqPMY4=";
      }
      {
        extName = "bluetooth";
        npmDepsHash = "sha256-F/vURwdEPwzZwlS4j0lGV8aN7VDGmdiV+WCy2vXN2Eo=";

        # usocket 0.3.0 requires `debug` without declaring it as a
        # dependency, so esbuild cannot resolve it; stub out the logger
        preBuild = ''
          substituteInPlace node_modules/usocket/index.js \
            --replace-fail "var debug = require('debug')(\"usocket\");" "var debug = function () { };"
        '';
      }
      {
        extName = "pdsls";
        type = "raycast";
        npmDepsHash = "sha256-I+eYqIPvnPOvDRJoS7ootxQ9Kg8FsfaJoT4VcEe+gLM=";
      }

      # broken
      # {
      #   extName = "mullvad";
      #   npmDepsHash = "sha256-WbnZtsTUMDHh2BojAjHUrca8aBw+OGXMMgX79Ek8wQ0=";
      # }
    ];
  };
}
