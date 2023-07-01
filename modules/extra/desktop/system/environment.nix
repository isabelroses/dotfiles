{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    environment.variables = {
      # open links with the default browser
      BROWSER = "chromium";
    };
  };
}
