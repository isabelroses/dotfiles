{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (osConfig.modules.usrEnv) programs;
  acceptedTypes = ["laptop" "desktop" "lite"];
in {
  imports = [
    ./mangohud
    ./minecraft
    ./steam
  ];

  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && programs.gaming.enable) {
    home = {
      packages = with pkgs; [
        gamescope
        legendary-gl
        mono
        winetricks
        mangohud
        lutris
        #dolphin-emu # cool emulator
        #yuzu # switch emulator
        dotnet-runtime_6 # needed by terraria
      ];
    };
  };
}
