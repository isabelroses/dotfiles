{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf (lib.isWayland osConfig) {
    home.packages =
      with pkgs;
      [
        swappy # used for screenshot area selection
        wl-gammactl
      ]
      ++ lib.optionals osConfig.modules.system.sound.enable [ pavucontrol ];
  };
}
