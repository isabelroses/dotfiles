{
  config,
  lib,
  ...
}: let
  progs = config.modules.usrEnv.programs.defaults;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = lib.mkIf (lib.isAcceptedDevice config acceptedTypes) {
    environment.variables = {
      # open links with the default browser
      BROWSER = progs.browser;
    };
  };
}
