{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];
in
{
  config =
    lib.mkIf
      (
        (lib.isAcceptedDevice osConfig acceptedTypes)
        && (lib.isWayland osConfig)
        && osConfig.modules.programs.gui.enable
      )
      {
        home.packages =
          with pkgs;
          [
            swappy # used for screenshot area selection
            wl-gammactl
          ]
          ++ lib.optionals osConfig.modules.system.sound.enable [ pavucontrol ];
      };
}
